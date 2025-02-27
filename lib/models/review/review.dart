class Review {
  String reviewId;
  String userId;
  String destinationId;
  double rating;
  String comment;
  DateTime date;

  Review({
    required this.reviewId,
    required this.userId,
    required this.destinationId,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? '',
      userId: json['userId'] ?? '',
      destinationId: json['destinationId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'destinationId': destinationId,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
}
