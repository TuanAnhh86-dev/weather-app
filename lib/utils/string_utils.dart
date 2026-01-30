// lib/utils/string_utils.dart
class StringUtils {
  static String removeVietnameseDiacritics(String str) {
    const withDiacritics = 'àáạảãâầấậẩẫăằắặẳẵ'
        'èéẹẻẽêềếệểễ'
        'ìíịỉĩ'
        'òóọỏõôồốộổỗơờớợởỡ'
        'ùúụủũưừứựửữ'
        'ỳýỵỷỹ'
        'đ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ'
        'ÈÉẸẺẼÊỀẾỆỂỄ'
        'ÌÍỊỈĨ'
        'ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ'
        'ÙÚỤỦŨƯỪỨỰỬỮ'
        'ỲÝỴỶỸ'
        'Đ';

    const withoutDiacritics = 'aaaaaaaaaaaaaaaaa'
        'eeeeeeeeeee'
        'iiiii'
        'ooooooooooooooooo'
        'uuuuuuuuuuu'
        'yyyyy'
        'd'
        'AAAAAAAAAAAAAAAAA'
        'EEEEEEEEEEE'
        'IIIII'
        'OOOOOOOOOOOOOOOOO'
        'UUUUUUUUUUU'
        'YYYYY'
        'D';

    for (int i = 0; i < withDiacritics.length; i++) {
      str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return str;
  }
}
