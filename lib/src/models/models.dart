// Core models for Campus Hub application
// Aligns with backend DTOs from com.peeraid.backend.dto package

class LoginResponse {
  final String token;
  final int expiresAt;

  LoginResponse({required this.token, required this.expiresAt});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Backend may use `expiresAt` or `expiresIn`. Accept both.
    dynamic raw = json['expiresAt'] ?? json['expiresIn'] ?? json['expires'] ?? json['expires_in'];
    int parsed;
    if (raw == null) {
      parsed = 0;
    } else if (raw is int) {
      parsed = raw;
    } else if (raw is double) {
      parsed = raw.toInt();
    } else {
      parsed = int.tryParse(raw.toString()) ?? 0;
    }
    return LoginResponse(token: json['token'] as String, expiresAt: parsed);
  }
}

class UserDto {
  final int id;
  final String name;
  final String email;

  UserDto({required this.id, required this.name, required this.email});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}

class ResourceDto {
  final int id;
  final String name;
  final String description;
  final String category;
  final String resourceType;
  final String? imageUrl;
  final int userId;
  final String status;
  final String? dateAdded;

  ResourceDto({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.resourceType,
    this.imageUrl,
    required this.userId,
    required this.status,
    this.dateAdded,
  });

  factory ResourceDto.fromJson(Map<String, dynamic> json) {
    return ResourceDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      resourceType: json['resourceType'] as String,
      imageUrl: json['imageUrl'] as String?,
      userId: (json['userId'] as num).toInt(),
      status: json['status'] as String,
      dateAdded: json['dateAdded']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'resourceType': resourceType,
        'imageUrl': imageUrl,
        'userId': userId,
        'status': status,
        'dateAdded': dateAdded,
      };
}

class CreateResourceRequest {
  final String name;
  final String description;
  final String category;
  final String resourceType;

  CreateResourceRequest({
    required this.name,
    required this.description,
    required this.category,
    required this.resourceType,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'category': category,
        'resourceType': resourceType,
      };
}

class UserRequestDto {
  final int id;
  final ResourceDto resourceDto;
  final UserDto lender;
  final UserDto borrower;
  final String status;
  final String type;
  final String? requestDate;
  final String? returnDate;

  UserRequestDto({
    required this.id,
    required this.resourceDto,
    required this.lender,
    required this.borrower,
    required this.status,
    required this.type,
    this.requestDate,
    this.returnDate,
  });

  factory UserRequestDto.fromJson(Map<String, dynamic> json) {
    return UserRequestDto(
      id: (json['id'] as num).toInt(),
      resourceDto: ResourceDto.fromJson(json['resourceDto'] as Map<String, dynamic>),
      lender: UserDto.fromJson(json['lender'] as Map<String, dynamic>),
      borrower: UserDto.fromJson(json['borrower'] as Map<String, dynamic>),
      status: json['status'] as String? ?? '',
      type: json['type'] as String? ?? '',
      requestDate: json['requestDate']?.toString(),
      returnDate: json['returnDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'resourceDto': resourceDto.toJson(),
        'lender': lender.toJson(),
        'borrower': borrower.toJson(),
        'status': status,
        'type': type,
        'requestDate': requestDate,
        'returnDate': returnDate,
      };
}

class TransactionRecordDto {
  final int id;
  final UserDto lender;
  final UserDto borrower;
  final ResourceDto resource;
  final String transactionStatus;
  final String? startDate;
  final String? endDate;

  TransactionRecordDto({
    required this.id,
    required this.lender,
    required this.borrower,
    required this.resource,
    required this.transactionStatus,
    this.startDate,
    this.endDate,
  });

  factory TransactionRecordDto.fromJson(Map<String, dynamic> json) {
    return TransactionRecordDto(
      id: (json['id'] as num).toInt(),
      lender: UserDto.fromJson(json['lender'] as Map<String, dynamic>),
      borrower: UserDto.fromJson(json['borrower'] as Map<String, dynamic>),
      resource: ResourceDto.fromJson(json['resource'] as Map<String, dynamic>),
      transactionStatus: json['transactionStatus'] as String? ?? '',
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lender': lender.toJson(),
        'borrower': borrower.toJson(),
        'resource': resource.toJson(),
        'transactionStatus': transactionStatus,
        'startDate': startDate,
        'endDate': endDate,
      };
}

class DonationRecordDto {
  final int id;
  final ResourceDto resource;

  DonationRecordDto({required this.id, required this.resource});

  factory DonationRecordDto.fromJson(Map<String, dynamic> json) {
    return DonationRecordDto(
      id: (json['id'] as num).toInt(),
      resource: ResourceDto.fromJson(json['resource'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'resource': resource.toJson(),
      };
}

