import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/spot_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/rating_model.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/rating_repository.dart';
import '../../data/repositories/spot_repository.dart';
import 'star_rating.dart';
import '../../../auth/providers/auth_provider.dart';

class SpotContent extends StatefulWidget {
  final Spot spot;

  const SpotContent({super.key, required this.spot});

  @override
  State<SpotContent> createState() => _SpotContentState();
}

class _SpotContentState extends State<SpotContent> {
  late final ComentarioRepository _repo;
  late final RatingRepository _ratingRepo;
  late final SpotRepository _spotRepo;
  late final AuthProvider _authProvider;
  List<Comment> _comments = [];
  bool _isLoading = true;
  late Spot _spot;
  int? _userRating;
  bool _ratingLoading = true;
  final TextEditingController _commentController = TextEditingController();
  bool _commentSubmitting = false;
  bool _commentsLoading = true;
  final Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _spot = widget.spot;
    _ratingRepo = Provider.of<RatingRepository>(context, listen: false);
    _spotRepo = Provider.of<SpotRepository>(context, listen: false);
    _repo = Provider.of<ComentarioRepository>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadAll();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadComments(), _loadUserRating()]);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadComments() async {
    if (!mounted) return;
    setState(() {
      _commentsLoading = true;
    });
    List<Comment> fetched = [];
    try {
      fetched = await _repo.fetchForSpot(widget.spot.id);
    } catch (_) {
      fetched = [];
    }
    if (!mounted) return;
    setState(() {
      _comments = fetched;
    });

    final idsToFetch = _comments
        .map((c) => c.userId)
        .toSet()
        .where((id) => id.isNotEmpty && !_userNames.containsKey(id))
        .toList();

    if (idsToFetch.isNotEmpty) {
      try {
        final names = await _repo.fetchUserNames(idsToFetch);
        if (!mounted) return;
        setState(() {
          _userNames.addAll(names);
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          for (final id in idsToFetch) {
            _userNames[id] = '';
          }
        });
      }
    }

    if (!mounted) return;
    setState(() {
      _commentsLoading = false;
    });
  }

  Future<void> _loadUserRating() async {
    final user = _authProvider.currentUser; 
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _userRating = null;
        _ratingLoading = false;
      });
      return;
    }
    final fetched = await _ratingRepo.fetchUserRating(widget.spot.id, user.id);
    if (!mounted) return;
    setState(() {
      _userRating = fetched;
      _ratingLoading = false;
    });
  }

  Future<void> _reloadSpot() async {
    final updated = await _spotRepo.fetchSpotById(widget.spot.id);
    if (mounted && updated != null) {
      setState(() {
        _spot = updated;
      });
    }
  }

  Future<void> _submitRating(int value) async {
    final user = _authProvider.currentUser;
    if (user == null) return;
    if (!mounted) return;
    setState(() {
      _ratingLoading = true;
    });
    final rating = Rating(spotId: widget.spot.id, userId: user.id, value: value, createdAt: DateTime.now());
    final success = await _ratingRepo.insertRating(rating);
    if (success) {
      await _reloadSpot();
      await _loadUserRating();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valoración enviada correctamente!'), backgroundColor: Colors.green));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar valoración'), backgroundColor: Colors.red));
    }
    if (!mounted) return;
    setState(() {
      _ratingLoading = false;
    });
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    final user = _authProvider.currentUser;
    final messenger = ScaffoldMessenger.of(context); 
    if (user == null) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Necesitas iniciar sesión para comentar'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (text.isEmpty) return;
    if (!mounted) return;

    setState(() {
      _commentSubmitting = true;
    });

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final tempComment = Comment(
      id: tempId,
      spotId: widget.spot.id,
      userId: user.id,
      text: text,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    setState(() {
      _comments.insert(0, tempComment);
      _commentController.clear();
    });

    bool success = false;
    try {
      success = await _repo.insertComentario(Comment(
        id: 0,
        spotId: widget.spot.id,
        userId: user.id,
        text: text,
        createdAt: DateTime.now(),
      ));
    } catch (_) {
      success = false;
    }

    if (!mounted) return;
    if (success) {
      await _loadComments();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Comentario publicado'),
        backgroundColor: Colors.green,
      ));
    } else {
      setState(() {
        _comments.removeWhere((c) => c.id == tempId);
      });
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Error al publicar comentario'),
        backgroundColor: Colors.red,
      ));
    }

    if (!mounted) return;
    setState(() {
      _commentSubmitting = false;
    });
  }

  Future<void> _deleteComment(Comment comment) async {
    final user = _authProvider.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Necesitas iniciar sesión'), backgroundColor: Colors.red));
      return;
    }
    final canDelete = comment.userId == user.id || _spot.esMio;
    if (!canDelete) return;
    final backupIndex = _comments.indexWhere((c) => c.id == comment.id);
    Comment? backup;
    if (backupIndex != -1) {
      backup = _comments[backupIndex];
      if (!mounted) return;
      setState(() {
        _comments.removeAt(backupIndex);
      });
    }
    bool success = false;
    try {
      success = await _repo.deleteComentario(comment.id);
    } catch (_) {
      success = false;
    }
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comentario eliminado'), backgroundColor: Colors.green));
    } else {
      if (backup != null) {
        setState(() {
          _comments.insert(backupIndex, backup!);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar comentario'), backgroundColor: Colors.red));
    }
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} m';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 20),
            _buildDescription(),
            const SizedBox(height: 24),
            _buildRatingCard(),
            const SizedBox(height: 28),
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _spot.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    '${_spot.ciudad}, ${_spot.pais}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _ratingLoading
                ? const SizedBox(width: 100, height: 28, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final filled = (_userRating ?? 0) >= starIndex;
                      return GestureDetector(
                        onTap: () => _submitRating(starIndex),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            filled ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      );
                    }),
                  ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    if (_spot.descripcion != null && _spot.descripcion!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descripción',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _spot.descripcion!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      );
    } else {
      return const Text(
        'Sin descripción',
        style: TextStyle(color: Colors.white24),
      );
    }
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E28),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Valoración',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _spot.valoracionMedia != null ? _spot.valoracionMedia!.toStringAsFixed(1) : '—',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_spot.totalValoraciones} valoraciones',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              StarRating(rating: _spot.valoracionMedia),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentarios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Escribe un comentario...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF16161A),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            const SizedBox(width: 8),
            _commentSubmitting
                ? const SizedBox(width: 40, height: 40, child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))))
                : IconButton(
                    onPressed: _submitComment,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading || _commentsLoading)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          const Text('Sin comentarios', style: TextStyle(color: Colors.white24))
        else
          Column(
            children: _comments.map((c) {
              final displayName = _userNames[c.userId] != null && _userNames[c.userId]!.isNotEmpty
                  ? _userNames[c.userId]!
                  : (c.userId.length > 8 ? '${c.userId.substring(0, 8)}...' : c.userId);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$displayName · ${_formatTime(c.createdAt)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.text,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Builder(builder: (context) {
                      final currentUser = _authProvider.currentUser;
                      final canDelete = currentUser != null && (c.userId == currentUser.id || _spot.esMio);
                      if (!canDelete) return const SizedBox.shrink();
                      return IconButton(
                        onPressed: () => _deleteComment(c),
                        icon: const Icon(Icons.delete_outline, color: Colors.white54),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}