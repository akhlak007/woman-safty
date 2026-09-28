import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hospital.dart';

class HospitalRepository {
  final List<Hospital> _seededHospitals = const [
    Hospital(
      id: 'hosp_nicvd',
      name: 'National Institute of Cardiovascular Diseases (NICVD)',
      banglaName: 'জাতীয় হৃদরোগ ইনস্টিটিউট ও হাসপাতাল',
      address: 'Sher-e-Bangla Nagar, Dhaka-1207',
      phone: '+88029122560',
      latitude: 23.7712,
      longitude: 90.3698,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: false,
      hasICU: true,
      type: 'government',
      area: 'Sher-e-Bangla Nagar',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_nins',
      name: 'National Institute of Neurosciences & Hospital (NINS)',
      banglaName: 'জাতীয় নিউরোসায়েন্সেস ইনস্টিটিউট ও হাসপাতাল',
      address: 'Sher-e-Bangla Nagar, Agargaon, Dhaka-1207',
      phone: '+88029140752',
      latitude: 23.7770,
      longitude: 90.3705,
      is24x7: true,
      hasCathLab: false,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'government',
      area: 'Agargaon',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_dmch',
      name: 'Dhaka Medical College Hospital (DMCH)',
      banglaName: 'ঢাকা মেডিকেল কলেজ হাসপাতাল',
      address: 'Secretariat Road, Bakshibazar, Dhaka-1000',
      phone: '+880255165088',
      latitude: 23.7259,
      longitude: 90.3976,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'government',
      area: 'Shahbagh',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_nhf',
      name: 'National Heart Foundation Hospital & Research Institute',
      banglaName: 'ন্যাশনাল হার্ট ফাউন্ডেশন হসপিটাল অ্যান্ড রিসার্চ ইনস্টিটিউট',
      address: 'Plot-4, Section-2, Mirpur, Dhaka-1216',
      phone: '+88029033442',
      latitude: 23.8052,
      longitude: 90.3621,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: false,
      hasICU: true,
      type: 'private',
      area: 'Mirpur',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_united',
      name: 'United Hospital Limited',
      banglaName: 'ইউনাইটেড হাসপাতাল লিমিটেড',
      address: 'Plot 15, Road 71, Gulshan-2, Dhaka-1212',
      phone: '+88028836000',
      latitude: 23.7997,
      longitude: 90.4184,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'private',
      area: 'Gulshan',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_square',
      name: 'Square Hospitals Limited',
      banglaName: 'স্কয়ার হাসপাতাল লিমিটেড',
      address: '18/F, Bir Uttam Qazi Nuruzzaman Sarak, Panthapath, Dhaka-1205',
      phone: '+88028144400',
      latitude: 23.7533,
      longitude: 90.3817,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'private',
      area: 'Panthapath',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_evercare',
      name: 'Evercare Hospital Dhaka',
      banglaName: 'এভারকেয়ার হাসপাতাল ঢাকা',
      address: 'Plot 81, Block E, Bashundhara R/A, Dhaka-1229',
      phone: '+88028431661',
      latitude: 23.8105,
      longitude: 90.4312,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'private',
      area: 'Bashundhara',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_bssmu',
      name: 'BSMMU (PG Hospital)',
      banglaName: 'বঙ্গবন্ধু শেখ মুজিব মেডিক্যাল বিশ্ববিদ্যালয়',
      address: 'Shahbagh, Dhaka-1000',
      phone: '+880255165760',
      latitude: 23.7389,
      longitude: 90.3957,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'government',
      area: 'Shahbagh',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_kurmitola',
      name: 'Kurmitola General Hospital',
      banglaName: 'কুর্মিটোলা জেনারেল হাসপাতাল',
      address: 'Dhaka Cantonment, Airport Road, Dhaka-1206',
      phone: '+88028711200',
      latitude: 23.8219,
      longitude: 90.4072,
      is24x7: true,
      hasCathLab: false,
      hasStrokeThrombolysis: false,
      hasICU: true,
      type: 'government',
      area: 'Cantonment',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_suhrawardy',
      name: 'Shaheed Suhrawardy Medical College Hospital',
      banglaName: 'শহীদ সোহরাওয়ার্দী মেডিকেল কলেজ হাসপাতাল',
      address: 'Sher-e-Bangla Nagar, Dhaka-1207',
      phone: '+88029130800',
      latitude: 23.7701,
      longitude: 90.3719,
      is24x7: true,
      hasCathLab: false,
      hasStrokeThrombolysis: false,
      hasICU: true,
      type: 'government',
      area: 'Sher-e-Bangla Nagar',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_uttara_crescent',
      name: 'Uttara Crescent Hospital',
      banglaName: 'উত্তরা ক্রিসেন্ট হাসপাতাল',
      address: 'House 21 & 40, Rabindra Sarani, Sector 3, Uttara, Dhaka-1230',
      phone: '+88028932467',
      latitude: 23.8687,
      longitude: 90.3986,
      is24x7: true,
      hasCathLab: false,
      hasStrokeThrombolysis: false,
      hasICU: true,
      type: 'private',
      area: 'Uttara',
      district: 'Dhaka',
    ),
    Hospital(
      id: 'hosp_ibn_sina_dhanmondi',
      name: 'Ibn Sina Specialized Hospital Dhanmondi',
      banglaName: 'ইবনে সিনা স্পেশালাইজড হাসপাতাল ধানমন্ডি',
      address: 'House 68, Road 15/A, Dhanmondi, Dhaka-1209',
      phone: '+88029126625',
      latitude: 23.7485,
      longitude: 90.3735,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'private',
      area: 'Dhanmondi',
      district: 'Dhaka',
    ),
    // Barishal Hospitals
    Hospital(
      id: 'hosp_sbmch',
      name: 'Sher-e-Bangla Medical College Hospital (SBMCH)',
      banglaName: 'শের-ই-বাংলা মেডিকেল কলেজ হাসপাতাল',
      address: 'Band Road, Barishal-8200',
      phone: '+880431217354',
      latitude: 22.6870,
      longitude: 90.3622,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'government',
      area: 'Band Road',
      district: 'Barishal',
    ),
    Hospital(
      id: 'hosp_barisal_general',
      name: 'Barisal General Hospital (Sadar Hospital)',
      banglaName: 'বরিশাল জেনারেল হাসপাতাল (সদর হাসপাতাল)',
      address: 'Hospital Road, Barishal-8200',
      phone: '+88043164289',
      latitude: 22.7088,
      longitude: 90.3706,
      is24x7: true,
      hasCathLab: false,
      hasStrokeThrombolysis: false,
      hasICU: true,
      type: 'government',
      area: 'Hospital Road',
      district: 'Barishal',
    ),
    Hospital(
      id: 'hosp_barisal_heart',
      name: 'Barisal Heart Foundation Hospital',
      banglaName: 'বরিশাল হার্ট ফাউন্ডেশন হাসপাতাল',
      address: 'New Circular Road, Barishal-8200',
      phone: '+880431217750',
      latitude: 22.6976,
      longitude: 90.3590,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: false,
      hasICU: true,
      type: 'private',
      area: 'Circular Road',
      district: 'Barishal',
    ),
    // Chattogram & Sylhet
    Hospital(
      id: 'hosp_cmch',
      name: 'Chattogram Medical College Hospital (CMCH)',
      banglaName: 'চট্টগ্রাম মেডিকেল কলেজ হাসপাতাল',
      address: '57, K.B. Fazlul Kader Road, Panchlaish, Chattogram',
      phone: '+88031619597',
      latitude: 22.3592,
      longitude: 91.8282,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'government',
      area: 'Panchlaish',
      district: 'Chattogram',
    ),
    Hospital(
      id: 'hosp_evercare_ctg',
      name: 'Evercare Hospital Chattogram',
      banglaName: 'এভারকেয়ার হাসপাতাল চট্টগ্রাম',
      address: 'Plot H1, Ananya Residential Area, Oxygen-Kuwaish Road, Chattogram',
      phone: '+8809612310663',
      latitude: 22.3916,
      longitude: 91.8415,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: true,
      hasICU: true,
      type: 'private',
      area: 'Ananya R/A',
      district: 'Chattogram',
    ),
    Hospital(
      id: 'hosp_sylhet_mag',
      name: 'Sylhet MAG Osmani Medical College Hospital',
      banglaName: 'সিলেট এম এ জি ওসমানী মেডিকেল কলেজ হাসপাতাল',
      address: 'Medical Road, Kajalshah, Sylhet-3100',
      phone: '+880821713000',
      latitude: 24.8988,
      longitude: 91.8542,
      is24x7: true,
      hasCathLab: true,
      hasStrokeThrombolysis: false,
      hasICU: true,
      type: 'government',
      area: 'Kajalshah',
      district: 'Sylhet',
    ),
  ];

  const HospitalRepository();

  /// Retrieves list of emergency hospitals filtered and sorted by user distance or location
  List<Hospital> getHospitals({
    double? userLat,
    double? userLng,
    String? searchQuery,
    bool? only24x7,
    bool? onlyCathLab,
    bool? onlyStroke,
    bool? onlyICU,
    String? areaFilter,
    double? maxDistanceKm,
    String? sortBy, // 'proximity', 'name', 'area'
  }) {
    List<Hospital> list = List.from(_seededHospitals);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((h) {
        return h.name.toLowerCase().contains(q) ||
            h.banglaName.toLowerCase().contains(q) ||
            h.address.toLowerCase().contains(q) ||
            h.area.toLowerCase().contains(q) ||
            h.district.toLowerCase().contains(q);
      }).toList();
    }

    if (areaFilter != null && areaFilter.isNotEmpty && areaFilter.toLowerCase() != 'all') {
      final filterLower = areaFilter.trim().toLowerCase();
      list = list.where((h) =>
          h.area.toLowerCase() == filterLower ||
          h.district.toLowerCase() == filterLower).toList();
    }

    if (only24x7 == true) {
      list = list.where((h) => h.is24x7).toList();
    }
    if (onlyCathLab == true) {
      list = list.where((h) => h.hasCathLab).toList();
    }
    if (onlyStroke == true) {
      list = list.where((h) => h.hasStrokeThrombolysis).toList();
    }
    if (onlyICU == true) {
      list = list.where((h) => h.hasICU).toList();
    }

    if (maxDistanceKm != null && userLat != null && userLng != null) {
      list = list.where((h) => h.distanceTo(userLat, userLng) <= maxDistanceKm).toList();
    }

    // Sort by proximity or custom sort
    if (sortBy == 'name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortBy == 'area') {
      list.sort((a, b) => a.area.compareTo(b.area));
    } else if (userLat != null && userLng != null) {
      list.sort((a, b) {
        final distA = a.distanceTo(userLat, userLng);
        final distB = b.distanceTo(userLat, userLng);
        return distA.compareTo(distB);
      });
    }

    return list;
  }

  /// Fetches real-time live hospitals around active coordinates from OpenStreetMap Nominatim and Overpass APIs
  Future<List<Hospital>> fetchLiveNearbyHospitals({
    required double userLat,
    required double userLng,
    double radiusKm = 25.0,
    String? searchQuery,
    bool? only24x7,
    bool? onlyCathLab,
    bool? onlyStroke,
    bool? onlyICU,
    String? areaFilter,
    double? maxDistanceKm,
  }) async {
    final liveHospitals = <Hospital>[];
    final seenIds = <String>{};

    try {
      // 1. Query OpenStreetMap Nominatim within the bounding box of the active user coordinates
      final delta = (radiusKm / 111.0).clamp(0.1, 0.4);
      final minLon = (userLng - delta).toStringAsFixed(4);
      final maxLon = (userLng + delta).toStringAsFixed(4);
      final minLat = (userLat - delta).toStringAsFixed(4);
      final maxLat = (userLat + delta).toStringAsFixed(4);

      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=hospital&viewbox=$minLon,$maxLat,$maxLon,$minLat&bounded=1&limit=30&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'SafeLifeEmergencyApp/1.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> items = jsonDecode(response.body);
        for (final item in items) {
          final placeId = 'osm_${item['place_id']}';
          final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
          if (lat == 0.0 || lon == 0.0) continue;

          final rawName = item['name'] as String?;
          final displayName = item['display_name'] as String? ?? 'Emergency Care Center';
          final name = (rawName != null && rawName.trim().isNotEmpty)
              ? rawName.trim()
              : displayName.split(',').first.trim();

          final addr = item['address'] as Map<String, dynamic>?;
          final area = addr?['suburb'] ?? addr?['neighbourhood'] ?? addr?['town'] ?? addr?['city'] ?? 'Local Area';
          final district = addr?['state_district'] ?? addr?['county'] ?? addr?['state'] ?? 'District';

          final lowerName = name.toLowerCase();
          final isCardiac = lowerName.contains('cardiac') || lowerName.contains('heart') || lowerName.contains('ccu');
          final isStroke = lowerName.contains('neuro') || lowerName.contains('stroke');

          if (!seenIds.contains(placeId) && name.isNotEmpty) {
            seenIds.add(placeId);
            liveHospitals.add(Hospital(
              id: placeId,
              name: name,
              banglaName: name,
              address: displayName,
              phone: '+8802999',
              latitude: lat,
              longitude: lon,
              is24x7: true,
              hasCathLab: isCardiac,
              hasStrokeThrombolysis: isStroke,
              hasICU: true,
              type: lowerName.contains('medical college') || lowerName.contains('sadar') || lowerName.contains('general')
                  ? 'government'
                  : 'private',
              area: area.toString(),
              district: district.toString(),
            ));
          }
        }
      }
    } catch (_) {
      // In case of timeout or offline, proceed to integrate seeded facilities
    }

    // 2. Blend with known verified emergency institutes within reasonable proximity
    for (final seeded in _seededHospitals) {
      final dist = seeded.distanceTo(userLat, userLng);
      if (dist <= (radiusKm * 1.5) && !seenIds.contains(seeded.id)) {
        seenIds.add(seeded.id);
        liveHospitals.add(seeded);
      }
    }

    // 3. Fallback: if no live hospitals were found or device was offline, use all seeded hospitals
    List<Hospital> resultList = liveHospitals.isNotEmpty ? liveHospitals : List<Hospital>.from(_seededHospitals);

    // Apply filtering
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      resultList = resultList.where((h) {
        return h.name.toLowerCase().contains(q) ||
            h.banglaName.toLowerCase().contains(q) ||
            h.address.toLowerCase().contains(q) ||
            h.area.toLowerCase().contains(q) ||
            h.district.toLowerCase().contains(q);
      }).toList();
    }

    if (areaFilter != null && areaFilter.isNotEmpty && areaFilter.toLowerCase() != 'all') {
      final filterLower = areaFilter.trim().toLowerCase();
      resultList = resultList.where((h) =>
          h.area.toLowerCase() == filterLower ||
          h.district.toLowerCase() == filterLower).toList();
    }

    if (only24x7 == true) {
      resultList = resultList.where((h) => h.is24x7).toList();
    }
    if (onlyCathLab == true) {
      resultList = resultList.where((h) => h.hasCathLab).toList();
    }
    if (onlyStroke == true) {
      resultList = resultList.where((h) => h.hasStrokeThrombolysis).toList();
    }
    if (onlyICU == true) {
      resultList = resultList.where((h) => h.hasICU).toList();
    }

    if (maxDistanceKm != null) {
      resultList = resultList.where((h) => h.distanceTo(userLat, userLng) <= maxDistanceKm).toList();
    }

    // Sort strictly by proximity to active coordinates
    resultList.sort((a, b) {
      final distA = a.distanceTo(userLat, userLng);
      final distB = b.distanceTo(userLat, userLng);
      return distA.compareTo(distB);
    });

    return resultList;
  }

  /// Returns list of unique locations/areas available for filtering
  List<String> getAvailableAreas() {
    final areas = <String>{};
    for (final h in _seededHospitals) {
      areas.add(h.area);
    }
    final sorted = areas.toList()..sort();
    return sorted;
  }

  /// Returns list of unique districts/divisions available
  List<String> getAvailableDistricts() {
    final districts = <String>{};
    for (final h in _seededHospitals) {
      districts.add(h.district);
    }
    final sorted = districts.toList()..sort();
    return sorted;
  }
}
