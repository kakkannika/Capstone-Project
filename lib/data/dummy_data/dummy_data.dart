// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:tourism_app/models/place/place.dart';

// List<Place> dummyPlaces = [
//   Place(
//     id: "H1",
//     name: "Royal Palace",
//     description:
//         "The Royal Palace in Phnom Penh is a stunning complex of buildings that serves as the official residence of the King of Cambodia. It's a must-see attraction for visitors to the city, offering a glimpse into the rich history and culture of Cambodia.",
//     location: GeoPoint(11.563915192723806, 104.93124361897165),
//     imageURL:
//         "https://media-cdn.tripadvisor.com/media/photo-c/2560x500/10/e4/ce/b1/20171006-093816-01-largejpg.jpg",
//     category: PlaceCategory.historical_place,
//     averageRating: 4.0,
//     entranceFees: 0.25,
//     openingHours: "8:00-17:00",
//   ),
//   Place(
//     id: "H2",
//     name: "Wat Phnom",
//     description:
//         "Wat Phnom is a Buddhist temple in Doun Penh, Phnom Penh. It is a pagoda, that symbolizes the name of Phnom Penh, and a historical site that is part of the Khmer national identity. Wat Phnom has a total height of 46 meters.",
//     location: GeoPoint(11.57559165235394, 104.92279173774908),
//     imageURL:
//         "https://media-cdn.tripadvisor.com/media/photo-o/09/c7/fc/16/pagoda-wat-phnom.jpg",
//     category: PlaceCategory.historical_place,
//     averageRating: 4.0,
//     entranceFees: 0,
//     openingHours: "6:00-18:00",
//   ),
//   Place(
//     id: "H3",
//     name: "Independence Monument",
//     description:
//         "The Independence Monument in Phnom Penh, capital of Cambodia, was built in 1958 to memorialize Cambodia's independence from France in 1953. It stands on a roundabout in the intersection of Norodom Boulevard and Sihanouk Boulevard in the center of the city.",
//     location: GeoPoint(11.556666160296219, 104.928456882754),
//     imageURL:
//         "https://media-cdn.tripadvisor.com/media/photo-o/0b/d7/46/a0/the-independence-monument.jpg",
//     category: PlaceCategory.historical_place,
//     averageRating: 3.5,
//     entranceFees: 0,
//     openingHours: "24h",
//   ),
//   Place(
//     id: "MU1",
//     name: "National Museum",
//     description:
//         "The National Museum of Cambodia is Cambodia's largest museum of cultural history and is the country's leading historical and archaeological museum. It is located in Chey Chumneas, Phnom Penh.",
//     location: GeoPoint(11.565927865526413, 104.92916785309234),
//     imageURL:
//         "https://media-cdn.tripadvisor.com/media/photo-o/0c/aa/6a/cb/caption.jpg",
//     category: PlaceCategory.museum,
//     averageRating: 4.0,
//     entranceFees: 0.25,
//     openingHours: "8:00-17:00",
//   ),
//   Place(
//     id: "MU2",
//     name: "Choeung Ek Genocidal Museum",
//     description:
//         "Choeung Ek is a former orchard in Dangkao, Phnom Penh, Cambodia, that was used as a Killing Field between 1975 and 1979 by the Khmer Rouge in perpetrating the Cambodian genocide. Situated about 17 kilometers south of the city centre, it was attached to the Tuol Sleng detention centre.",
//     location: GeoPoint(11.484261216788582, 104.9012759954193),
//     imageURL:
//         "https://media-cdn.tripadvisor.com/media/photo-m/1280/19/f9/74/83/killing-field.jpg",
//     category: PlaceCategory.museum,
//     averageRating: 4.5,
//     entranceFees: 0,
//     openingHours: "8:00-17:00",
//   ),
//   Place(
//     id: "MA1",
//     name: "Phnom Penh's Night Market",
//     description:
//         "The Phnom Penh Night Market was a fun way to spend an evening. It's lively, filled with food stalls, clothing vendors, and a vibrant local crowd.",
//     location: GeoPoint(11.574160706064237, 104.92720442425656),
//     imageURL:
//         "https://media-cdn.tripadvisor.com/media/photo-o/02/4e/18/79/filename-120126-nightmarket.jpg",
//     category: PlaceCategory.market.toString(),
//     averageRating: 3.5,
//     entranceFees: 0,
//     openingHours: "17:00-24:00",
//   ),
//   Place(
//     id: "MA2",
//     name: "Central Market",
//     description:
//         "The Central Market, known as Phsar Thmey in Khmer, stands as a beacon of Phnom Penh’s rich culture and history. Opened in 1937, this market is not just a shopping destination but a landmark of architectural splendor. Its distinctive yellow dome, one of the largest in Asia, crowns a hub of bustling activity and cultural exchange.",
//     location: GeoPoint(11.569520456088785, 104.92090799542073),
//     imageURL:
//         "https://media-cdn.tripadvisor.com/media/photo-o/09/0b/c3/fd/central-market.jpg",
//     category: PlaceCategory.market.toString(),
//     averageRating: 4.0,
//     entranceFees: 0,
//     openingHours: "17:00-24:00",
//   ),
//   Place(
//     id: "MA3",
//     name: "Boeung Keng Kang 1 (BKK1) Market",
//     description:
//         "Boeung Keng Kang 1 (BKK1) Market is a trendy shopping area in Phnom Penh, known for its boutique shops, organic markets, and a variety of local and international food stalls. It’s a favorite spot for expats and young professionals.",
//     location: GeoPoint(11.547041964083396, 104.92568726933473),
//     imageURL:
//         "https://media-cdn.tripadvisor.com/media/photo-o/1a/2b/3c/4d/bkk1-market.jpg",
//     category: PlaceCategory.market.toString(),
//     averageRating: 4.1,
//     entranceFees: 0,
//     openingHours: "7:00-20:00",
//   ),
//   Place(
//     id: "ANG1",
//     name: "Angkor Wat",
//     description:
//         "Angkor Wat is the largest religious monument in the world, located in Siem Reap, Cambodia. This iconic temple, built in the 12th century, is a symbol of Khmer heritage and attracts millions of visitors each year.",
//     location: GeoPoint(13.4125, 103.8667),
//     imageURL:
//         "https://upload.wikimedia.org/wikipedia/commons/a/a8/Angkor_Wat_at_Sunrise.jpg",
//     category: PlaceCategory.historical_place.toString(),
//     averageRating: 4.8,
//     entranceFees: 37, // USD for a one-day pass
//     openingHours: "5:00-17:30",
// ),

// ];
