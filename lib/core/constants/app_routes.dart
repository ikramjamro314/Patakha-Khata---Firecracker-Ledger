/// All route paths — never hardcode route strings elsewhere.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String newBill = '/new-bill';
  static const String billPreview = '/bill-preview';
  static const String receipt = '/receipt';
  static const String history = '/history';
  static const String products = '/products';
  static const String productAdd = '/products/add';
  static const String productEdit = '/products/edit';

  static String productEditPath(String id) => '$productEdit/$id';
  static String receiptPath(String id) => '$receipt/$id';
}
