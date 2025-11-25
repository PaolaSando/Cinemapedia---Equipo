import 'package:flutter/material.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  static const name = 'search_screen';

  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    final searchType = ref.read(searchTypeProvider);

    if (query.isNotEmpty) {
      _performSearch(query, searchType);
    } else {
      ref.read(searchResultsProvider.notifier).clearResults();
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _performSearch(String query, SearchType searchType) async {
    setState(() {
      _isSearching = true;
    });

    try {
      await ref.read(searchResultsProvider.notifier).search(query, searchType);
    } catch (e) {
      // Manejar error si es necesario
      print('Error en búsqueda: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onSearchTypeChanged(SearchType? newType) {
    if (newType != null) {
      ref.read(searchTypeProvider.notifier).state = newType;
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _performSearch(query, newType);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchType = ref.watch(searchTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar películas o actores...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon:
                        _isSearching
                            ? CircularProgressIndicator()
                            : _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(searchResultsProvider.notifier)
                                    .clearResults();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Selector de tipo de búsqueda
                Row(
                  children: [
                    Text('Buscar por:'),
                    SizedBox(width: 16),
                    Row(
                      children: [
                        Radio<SearchType>(
                          value: SearchType.movie,
                          groupValue: searchType,
                          onChanged: _onSearchTypeChanged,
                        ),
                        Text('Película'),
                        SizedBox(width: 16),
                        Radio<SearchType>(
                          value: SearchType.actor,
                          groupValue: searchType,
                          onChanged: _onSearchTypeChanged,
                        ),
                        Text('Actor'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Resultados
          Expanded(
            child:
                _isSearching
                    ? Center(child: CircularProgressIndicator())
                    : _searchController.text.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Busca películas o actores',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : searchResults.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No se encontraron resultados',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = searchResults[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              movie.posterPath,
                              width: 50,
                              height: 75,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 75,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.movie),
                                );
                              },
                            ),
                          ),
                          title: Text(movie.title),
                          subtitle: Text(
                            '⭐ ${movie.voteAverage.toStringAsFixed(1)} • ${movie.releaseDate.year}',
                          ),
                          onTap: () {
                            context.push('/movie/${movie.id}');
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
