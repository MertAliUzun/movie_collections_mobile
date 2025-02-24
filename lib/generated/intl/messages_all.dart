// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_aa.dart' as messages_aa;
import 'messages_ab.dart' as messages_ab;
import 'messages_af.dart' as messages_af;
import 'messages_ak.dart' as messages_ak;
import 'messages_ar.dart' as messages_ar;
import 'messages_az.dart' as messages_az;
import 'messages_ba.dart' as messages_ba;
import 'messages_be.dart' as messages_be;
import 'messages_bg.dart' as messages_bg;
import 'messages_bm.dart' as messages_bm;
import 'messages_bn.dart' as messages_bn;
import 'messages_bs.dart' as messages_bs;
import 'messages_ca.dart' as messages_ca;
import 'messages_ce.dart' as messages_ce;
import 'messages_cs.dart' as messages_cs;
import 'messages_cv.dart' as messages_cv;
import 'messages_cy.dart' as messages_cy;
import 'messages_da.dart' as messages_da;
import 'messages_de.dart' as messages_de;
import 'messages_el.dart' as messages_el;
import 'messages_en.dart' as messages_en;
import 'messages_es.dart' as messages_es;
import 'messages_et.dart' as messages_et;
import 'messages_eu.dart' as messages_eu;
import 'messages_fa.dart' as messages_fa;
import 'messages_ff.dart' as messages_ff;
import 'messages_fi.dart' as messages_fi;
import 'messages_fr.dart' as messages_fr;
import 'messages_ga.dart' as messages_ga;
import 'messages_gd.dart' as messages_gd;
import 'messages_gu.dart' as messages_gu;
import 'messages_ha.dart' as messages_ha;
import 'messages_he.dart' as messages_he;
import 'messages_hi.dart' as messages_hi;
import 'messages_hr.dart' as messages_hr;
import 'messages_ht.dart' as messages_ht;
import 'messages_hu.dart' as messages_hu;
import 'messages_hy.dart' as messages_hy;
import 'messages_id.dart' as messages_id;
import 'messages_it.dart' as messages_it;
import 'messages_ja.dart' as messages_ja;
import 'messages_jv.dart' as messages_jv;
import 'messages_ka.dart' as messages_ka;
import 'messages_kg.dart' as messages_kg;
import 'messages_kk.dart' as messages_kk;
import 'messages_km.dart' as messages_km;
import 'messages_ko.dart' as messages_ko;
import 'messages_ks.dart' as messages_ks;
import 'messages_ku.dart' as messages_ku;
import 'messages_ky.dart' as messages_ky;
import 'messages_lb.dart' as messages_lb;
import 'messages_lt.dart' as messages_lt;
import 'messages_lv.dart' as messages_lv;
import 'messages_mk.dart' as messages_mk;
import 'messages_ml.dart' as messages_ml;
import 'messages_mn.dart' as messages_mn;
import 'messages_mr.dart' as messages_mr;
import 'messages_ms.dart' as messages_ms;
import 'messages_my.dart' as messages_my;
import 'messages_ne.dart' as messages_ne;
import 'messages_nl.dart' as messages_nl;
import 'messages_no.dart' as messages_no;
import 'messages_pa.dart' as messages_pa;
import 'messages_pl.dart' as messages_pl;
import 'messages_pt.dart' as messages_pt;
import 'messages_ro.dart' as messages_ro;
import 'messages_ru.dart' as messages_ru;
import 'messages_rw.dart' as messages_rw;
import 'messages_sd.dart' as messages_sd;
import 'messages_sk.dart' as messages_sk;
import 'messages_sl.dart' as messages_sl;
import 'messages_sm.dart' as messages_sm;
import 'messages_so.dart' as messages_so;
import 'messages_sq.dart' as messages_sq;
import 'messages_sr.dart' as messages_sr;
import 'messages_su.dart' as messages_su;
import 'messages_sv.dart' as messages_sv;
import 'messages_sw.dart' as messages_sw;
import 'messages_ta.dart' as messages_ta;
import 'messages_te.dart' as messages_te;
import 'messages_tg.dart' as messages_tg;
import 'messages_th.dart' as messages_th;
import 'messages_tk.dart' as messages_tk;
import 'messages_tr.dart' as messages_tr;
import 'messages_tt.dart' as messages_tt;
import 'messages_ug.dart' as messages_ug;
import 'messages_uk.dart' as messages_uk;
import 'messages_ur.dart' as messages_ur;
import 'messages_uz.dart' as messages_uz;
import 'messages_vi.dart' as messages_vi;
import 'messages_wo.dart' as messages_wo;
import 'messages_zh.dart' as messages_zh;
import 'messages_zu.dart' as messages_zu;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'aa': () => new SynchronousFuture(null),
  'ab': () => new SynchronousFuture(null),
  'af': () => new SynchronousFuture(null),
  'ak': () => new SynchronousFuture(null),
  'ar': () => new SynchronousFuture(null),
  'az': () => new SynchronousFuture(null),
  'ba': () => new SynchronousFuture(null),
  'be': () => new SynchronousFuture(null),
  'bg': () => new SynchronousFuture(null),
  'bm': () => new SynchronousFuture(null),
  'bn': () => new SynchronousFuture(null),
  'bs': () => new SynchronousFuture(null),
  'ca': () => new SynchronousFuture(null),
  'ce': () => new SynchronousFuture(null),
  'cs': () => new SynchronousFuture(null),
  'cv': () => new SynchronousFuture(null),
  'cy': () => new SynchronousFuture(null),
  'da': () => new SynchronousFuture(null),
  'de': () => new SynchronousFuture(null),
  'el': () => new SynchronousFuture(null),
  'en': () => new SynchronousFuture(null),
  'es': () => new SynchronousFuture(null),
  'et': () => new SynchronousFuture(null),
  'eu': () => new SynchronousFuture(null),
  'fa': () => new SynchronousFuture(null),
  'ff': () => new SynchronousFuture(null),
  'fi': () => new SynchronousFuture(null),
  'fr': () => new SynchronousFuture(null),
  'ga': () => new SynchronousFuture(null),
  'gd': () => new SynchronousFuture(null),
  'gu': () => new SynchronousFuture(null),
  'ha': () => new SynchronousFuture(null),
  'he': () => new SynchronousFuture(null),
  'hi': () => new SynchronousFuture(null),
  'hr': () => new SynchronousFuture(null),
  'ht': () => new SynchronousFuture(null),
  'hu': () => new SynchronousFuture(null),
  'hy': () => new SynchronousFuture(null),
  'id': () => new SynchronousFuture(null),
  'it': () => new SynchronousFuture(null),
  'ja': () => new SynchronousFuture(null),
  'jv': () => new SynchronousFuture(null),
  'ka': () => new SynchronousFuture(null),
  'kg': () => new SynchronousFuture(null),
  'kk': () => new SynchronousFuture(null),
  'km': () => new SynchronousFuture(null),
  'ko': () => new SynchronousFuture(null),
  'ks': () => new SynchronousFuture(null),
  'ku': () => new SynchronousFuture(null),
  'ky': () => new SynchronousFuture(null),
  'lb': () => new SynchronousFuture(null),
  'lt': () => new SynchronousFuture(null),
  'lv': () => new SynchronousFuture(null),
  'mk': () => new SynchronousFuture(null),
  'ml': () => new SynchronousFuture(null),
  'mn': () => new SynchronousFuture(null),
  'mr': () => new SynchronousFuture(null),
  'ms': () => new SynchronousFuture(null),
  'my': () => new SynchronousFuture(null),
  'ne': () => new SynchronousFuture(null),
  'nl': () => new SynchronousFuture(null),
  'no': () => new SynchronousFuture(null),
  'pa': () => new SynchronousFuture(null),
  'pl': () => new SynchronousFuture(null),
  'pt': () => new SynchronousFuture(null),
  'ro': () => new SynchronousFuture(null),
  'ru': () => new SynchronousFuture(null),
  'rw': () => new SynchronousFuture(null),
  'sd': () => new SynchronousFuture(null),
  'sk': () => new SynchronousFuture(null),
  'sl': () => new SynchronousFuture(null),
  'sm': () => new SynchronousFuture(null),
  'so': () => new SynchronousFuture(null),
  'sq': () => new SynchronousFuture(null),
  'sr': () => new SynchronousFuture(null),
  'su': () => new SynchronousFuture(null),
  'sv': () => new SynchronousFuture(null),
  'sw': () => new SynchronousFuture(null),
  'ta': () => new SynchronousFuture(null),
  'te': () => new SynchronousFuture(null),
  'tg': () => new SynchronousFuture(null),
  'th': () => new SynchronousFuture(null),
  'tk': () => new SynchronousFuture(null),
  'tr': () => new SynchronousFuture(null),
  'tt': () => new SynchronousFuture(null),
  'ug': () => new SynchronousFuture(null),
  'uk': () => new SynchronousFuture(null),
  'ur': () => new SynchronousFuture(null),
  'uz': () => new SynchronousFuture(null),
  'vi': () => new SynchronousFuture(null),
  'wo': () => new SynchronousFuture(null),
  'zh': () => new SynchronousFuture(null),
  'zu': () => new SynchronousFuture(null),
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'aa':
      return messages_aa.messages;
    case 'ab':
      return messages_ab.messages;
    case 'af':
      return messages_af.messages;
    case 'ak':
      return messages_ak.messages;
    case 'ar':
      return messages_ar.messages;
    case 'az':
      return messages_az.messages;
    case 'ba':
      return messages_ba.messages;
    case 'be':
      return messages_be.messages;
    case 'bg':
      return messages_bg.messages;
    case 'bm':
      return messages_bm.messages;
    case 'bn':
      return messages_bn.messages;
    case 'bs':
      return messages_bs.messages;
    case 'ca':
      return messages_ca.messages;
    case 'ce':
      return messages_ce.messages;
    case 'cs':
      return messages_cs.messages;
    case 'cv':
      return messages_cv.messages;
    case 'cy':
      return messages_cy.messages;
    case 'da':
      return messages_da.messages;
    case 'de':
      return messages_de.messages;
    case 'el':
      return messages_el.messages;
    case 'en':
      return messages_en.messages;
    case 'es':
      return messages_es.messages;
    case 'et':
      return messages_et.messages;
    case 'eu':
      return messages_eu.messages;
    case 'fa':
      return messages_fa.messages;
    case 'ff':
      return messages_ff.messages;
    case 'fi':
      return messages_fi.messages;
    case 'fr':
      return messages_fr.messages;
    case 'ga':
      return messages_ga.messages;
    case 'gd':
      return messages_gd.messages;
    case 'gu':
      return messages_gu.messages;
    case 'ha':
      return messages_ha.messages;
    case 'he':
      return messages_he.messages;
    case 'hi':
      return messages_hi.messages;
    case 'hr':
      return messages_hr.messages;
    case 'ht':
      return messages_ht.messages;
    case 'hu':
      return messages_hu.messages;
    case 'hy':
      return messages_hy.messages;
    case 'id':
      return messages_id.messages;
    case 'it':
      return messages_it.messages;
    case 'ja':
      return messages_ja.messages;
    case 'jv':
      return messages_jv.messages;
    case 'ka':
      return messages_ka.messages;
    case 'kg':
      return messages_kg.messages;
    case 'kk':
      return messages_kk.messages;
    case 'km':
      return messages_km.messages;
    case 'ko':
      return messages_ko.messages;
    case 'ks':
      return messages_ks.messages;
    case 'ku':
      return messages_ku.messages;
    case 'ky':
      return messages_ky.messages;
    case 'lb':
      return messages_lb.messages;
    case 'lt':
      return messages_lt.messages;
    case 'lv':
      return messages_lv.messages;
    case 'mk':
      return messages_mk.messages;
    case 'ml':
      return messages_ml.messages;
    case 'mn':
      return messages_mn.messages;
    case 'mr':
      return messages_mr.messages;
    case 'ms':
      return messages_ms.messages;
    case 'my':
      return messages_my.messages;
    case 'ne':
      return messages_ne.messages;
    case 'nl':
      return messages_nl.messages;
    case 'no':
      return messages_no.messages;
    case 'pa':
      return messages_pa.messages;
    case 'pl':
      return messages_pl.messages;
    case 'pt':
      return messages_pt.messages;
    case 'ro':
      return messages_ro.messages;
    case 'ru':
      return messages_ru.messages;
    case 'rw':
      return messages_rw.messages;
    case 'sd':
      return messages_sd.messages;
    case 'sk':
      return messages_sk.messages;
    case 'sl':
      return messages_sl.messages;
    case 'sm':
      return messages_sm.messages;
    case 'so':
      return messages_so.messages;
    case 'sq':
      return messages_sq.messages;
    case 'sr':
      return messages_sr.messages;
    case 'su':
      return messages_su.messages;
    case 'sv':
      return messages_sv.messages;
    case 'sw':
      return messages_sw.messages;
    case 'ta':
      return messages_ta.messages;
    case 'te':
      return messages_te.messages;
    case 'tg':
      return messages_tg.messages;
    case 'th':
      return messages_th.messages;
    case 'tk':
      return messages_tk.messages;
    case 'tr':
      return messages_tr.messages;
    case 'tt':
      return messages_tt.messages;
    case 'ug':
      return messages_ug.messages;
    case 'uk':
      return messages_uk.messages;
    case 'ur':
      return messages_ur.messages;
    case 'uz':
      return messages_uz.messages;
    case 'vi':
      return messages_vi.messages;
    case 'wo':
      return messages_wo.messages;
    case 'zh':
      return messages_zh.messages;
    case 'zu':
      return messages_zu.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) {
  var availableLocale = Intl.verifiedLocale(
      localeName, (locale) => _deferredLibraries[locale] != null,
      onFailure: (_) => null);
  if (availableLocale == null) {
    return new SynchronousFuture(false);
  }
  var lib = _deferredLibraries[availableLocale];
  lib == null ? new SynchronousFuture(false) : lib();
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new SynchronousFuture(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  var actualLocale =
      Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
