import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../../domain/entities/scientific_reference.dart';

/// Data source for scientific references
class ScientificReferenceDataSource {
  /// HTTP client
  final http.Client _client;
  
  /// PubMed API key
  final String? _apiKey;
  
  /// Cache box name
  static const String _cacheBoxName = 'scientific_references_cache';
  
  /// Cache box
  final Box _cacheBox;
  
  /// Cache TTL in hours
  static const int _cacheTtlHours = 24 * 7; // 1 week
  
  /// Create scientific reference data source
  ScientificReferenceDataSource({
    http.Client? client,
    String? apiKey,
    Box? cacheBox,
  }) : _client = client ?? http.Client(),
       _apiKey = apiKey,
       _cacheBox = cacheBox ?? Hive.box(_cacheBoxName);
  
  /// Initialize the data source
  static Future<void> initialize() async {
    try {
      await Hive.openBox(_cacheBoxName);
    } catch (e) {
      debugPrint('Error initializing scientific reference data source: $e');
      rethrow;
    }
  }
  
  /// Fetch scientific references for an ingredient
  Future<List<ScientificReference>> fetchReferences(String ingredient) async {
    try {
      // Check cache first
      final cacheKey = 'reference_${ingredient.toLowerCase().trim()}';
      final cacheData = _cacheBox.get(cacheKey);
      
      if (cacheData != null) {
        final cacheTime = DateTime.parse(cacheData['timestamp']);
        final now = DateTime.now();
        
        // Check if cache is still valid
        if (now.difference(cacheTime).inHours < _cacheTtlHours) {
          final cachedReferences = List<Map<String, dynamic>>.from(cacheData['references']);
          
          return cachedReferences.map((refData) => _mapToScientificReference(refData)).toList();
        }
      }
      
      // If not in cache or cache expired, fetch from API
      return await _fetchFromPubMed(ingredient);
    } catch (e) {
      debugPrint('Error fetching references: $e');
      
      // If API fails, try to use expired cache as fallback
      final cacheKey = 'reference_${ingredient.toLowerCase().trim()}';
      final cacheData = _cacheBox.get(cacheKey);
      
      if (cacheData != null) {
        final cachedReferences = List<Map<String, dynamic>>.from(cacheData['references']);
        return cachedReferences.map((refData) => _mapToScientificReference(refData)).toList();
      }
      
      return [];
    }
  }
  
  /// Fetch references from PubMed
  Future<List<ScientificReference>> _fetchFromPubMed(String ingredient) async {
    if (_apiKey == null) {
      debugPrint('PubMed API key not provided');
      return _fetchFallbackReferences(ingredient);
    }
    
    try {
      // Search for the ingredient in PubMed
      final searchUrl = Uri.parse(
        'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
        '?db=pubmed'
        '&term=$ingredient+skincare+safety'
        '&retmax=5'
        '&retmode=json'
        '&api_key=$_apiKey'
      );
      
      final searchResponse = await _client.get(searchUrl)
          .timeout(const Duration(seconds: 30));
      
      if (searchResponse.statusCode != 200) {
        throw Exception('Failed to search PubMed: ${searchResponse.statusCode}');
      }
      
      final searchData = json.decode(searchResponse.body);
      final List<String> ids = List<String>.from(searchData['esearchresult']['idlist']);
      
      if (ids.isEmpty) {
        return _fetchFallbackReferences(ingredient);
      }
      
      // Fetch details for the found articles
      final detailsUrl = Uri.parse(
        'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi'
        '?db=pubmed'
        '&id=${ids.join(",")}'
        '&retmode=json'
        '&api_key=$_apiKey'
      );
      
      final detailsResponse = await _client.get(detailsUrl)
          .timeout(const Duration(seconds: 30));
          
      if (detailsResponse.statusCode != 200) {
        throw Exception('Failed to get PubMed details: ${detailsResponse.statusCode}');
      }
      
      final detailsData = json.decode(detailsResponse.body);
      final result = _parseArticleDetails(detailsData, ids);
      
      // Cache the results
      final cacheKey = 'reference_${ingredient.toLowerCase().trim()}';
      await _cacheBox.put(cacheKey, {
        'timestamp': DateTime.now().toIso8601String(),
        'references': result.map((ref) => _scientificReferenceToMap(ref)).toList(),
      });
      
      return result;
    } catch (e) {
      debugPrint('Error fetching from PubMed: $e');
      return _fetchFallbackReferences(ingredient);
    }
  }
  
  /// Fetch fallback references
  Future<List<ScientificReference>> _fetchFallbackReferences(String ingredient) async {
    // In a real app, this would fetch from a local database
    // For now, return an empty list
    return [];
  }
  
  /// Parse article details from PubMed API response
  List<ScientificReference> _parseArticleDetails(
    Map<String, dynamic> detailsData,
    List<String> ids,
  ) {
    final result = <ScientificReference>[];
    
    for (final id in ids) {
      try {
        final article = detailsData['result'][id];
        
        if (article == null) continue;
        
        // Extract authors
        final authorList = article['authors'] as List?;
        final authors = authorList != null
            ? authorList.map((a) => '${a['name']}').toList().cast<String>()
            : <String>[];
        
        // Extract DOI from article IDs
        String? doi;
        final articleIds = article['articleids'] as List?;
        if (articleIds != null) {
          for (final idObj in articleIds) {
            if (idObj['idtype'] == 'doi') {
              doi = idObj['value'];
              break;
            }
          }
        }
        
        result.add(
          ScientificReference(
            pubMedId: id,
            doi: doi,
            title: article['title'] ?? 'Unknown Title',
            authors: authors,
            journal: article['fulljournalname'] ?? article['source'],
            year: article['pubdate'] != null
                ? int.tryParse(article['pubdate'].toString().split(' ').first)
                : null,
            summary: article['description'] ?? article['title'] ?? 'No summary available',
            verificationStatus: VerificationStatus.verified,
          ),
        );
      } catch (e) {
        debugPrint('Error parsing article $id: $e');
      }
    }
    
    return result;
  }
  
  /// Map scientific reference to map for caching
  Map<String, dynamic> _scientificReferenceToMap(ScientificReference reference) {
    return {
      'doi': reference.doi,
      'pubMedId': reference.pubMedId,
      'title': reference.title,
      'authors': reference.authors,
      'journal': reference.journal,
      'year': reference.year,
      'summary': reference.summary,
      'url': reference.url,
      'keywords': reference.keywords,
      'verificationStatus': reference.verificationStatus.index,
    };
  }
  
  /// Map from data to scientific reference
  ScientificReference _mapToScientificReference(Map<String, dynamic> data) {
    return ScientificReference(
      doi: data['doi'],
      pubMedId: data['pubMedId'],
      title: data['title'],
      authors: data['authors'] != null ? List<String>.from(data['authors']) : null,
      journal: data['journal'],
      year: data['year'],
      summary: data['summary'],
      url: data['url'],
      keywords: data['keywords'] != null ? List<String>.from(data['keywords']) : null,
      verificationStatus: VerificationStatus.values[data['verificationStatus'] ?? 0],
    );
  }
  
  /// Dispose resources
  void dispose() {
    _client.close();
  }
}