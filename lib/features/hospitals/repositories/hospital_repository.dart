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
    ),
  ];

  const HospitalRepository();

  /// Retrieves list of emergency hospitals filtered and sorted by user distance
  List<Hospital> getHospitals({
    double? userLat,
    double? userLng,
    String? searchQuery,
    bool? only24x7,
    bool? onlyCathLab,
    bool? onlyStroke,
    bool? onlyICU,
  }) {
    List<Hospital> list = List.from(_seededHospitals);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((h) {
        return h.name.toLowerCase().contains(q) ||
            h.banglaName.toLowerCase().contains(q) ||
            h.address.toLowerCase().contains(q);
      }).toList();
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

    // Sort by proximity if user coordinates are available
    if (userLat != null && userLng != null) {
      list.sort((a, b) {
        final distA = a.distanceTo(userLat, userLng);
        final distB = b.distanceTo(userLat, userLng);
        return distA.compareTo(distB);
      });
    }

    return list;
  }
}
