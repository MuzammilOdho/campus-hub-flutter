import 'package:campus_hub/src/api/api_service.dart';
import 'package:campus_hub/src/models/models.dart';
import 'dart:io';

class ResourceRepository {
  final ApiService api;
  ResourceRepository(this.api);

  Future<List<ResourceDto>> getResources({String type = 'All', String category = 'All', String status = 'Any', int page = 0, int size = 10}) => api.getResources(type: type, category: category, status: status, page: page, size: size);
  Future<ResourceDto> getResourceById(int id) => api.getResourceById(id);
  Future<void> createResource(CreateResourceRequest req, File? image) => api.createResource(req, image);
  Future<List<ResourceDto>> getMyResources({int page = 0, int size = 10}) => api.getMyResources(page: page, size: size);
  Future<String> deleteResource(int id) => api.deleteResource(id);
}

