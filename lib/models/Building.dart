class Building{
  final String uid;
  final String name;
  final String architect;
  final String studio;
  final int yearBegin;
  final int yearEnd;
  final int yearOpen;
  final String direction;
  final String description;
  final double lat;
  final double lon;
  final bool approved;
  final List<String> images;
  final String publishedBy;
  final String geohash;

  const Building({
    this.uid,
    this.name,
    this.architect,
    this.studio,
    this.yearBegin,
    this.yearEnd,
    this.yearOpen,
    this.direction,
    this.description,
    this.lat,
    this.lon,
    this.approved,
    this.images,
    this.publishedBy,
    this.geohash,
  });
}
