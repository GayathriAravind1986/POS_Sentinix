import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/Authentication/Post_login_model.dart';
import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart';
import 'package:simple/ModelClass/Order/Delete_order_model.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/ModelClass/Order/Post_generate_order_model.dart';
import 'package:simple/ModelClass/Order/Update_generate_order_model.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/ModelClass/ShopDetails/get_shop_details_model.dart';
import 'package:simple/Reusable/constant.dart';

import '../ModelClass/Table/Get_table_model.dart';

/// All API Integration in ApiProvider
class ApiProvider {
  late Dio _dio;

  /// dio use ApiProvider
  ApiProvider() {
    final options = BaseOptions(
        connectTimeout: const Duration(milliseconds: 150000),
        receiveTimeout: const Duration(milliseconds: 100000));
    _dio = Dio(options);
  }

  /// LoginWithOTP API Integration
  Future<PostLoginModel> loginAPI(
    String email,
    String password,
  ) async {
    try {
      final dataMap = {"email": email, "password": password};
      var data = json.encode(dataMap);
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}auth/users/login'.trim(),
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          PostLoginModel postLoginResponse =
              PostLoginModel.fromJson(response.data);
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(
            "token",
            postLoginResponse.token.toString(),
          );
          return postLoginResponse;
        }
      }
      return PostLoginModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return PostLoginModel()
          ..errorResponse = ErrorResponse(message: "Invalid email or password");
      } else {
        return PostLoginModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return PostLoginModel()..errorResponse = handleError(error);
    }
  }

  /// Category - Fetch API Integration
  Future<GetCategoryModel> getCategoryAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/categories',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetCategoryModel getCategoryResponse =
              GetCategoryModel.fromJson(response.data);
          return getCategoryResponse;
        }
      } else {
        return GetCategoryModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
          );
      }
      return GetCategoryModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return GetCategoryModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return GetCategoryModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return GetCategoryModel()..errorResponse = handleError(error);
    }
  }

  /// product - Fetch API Integration
  Future<GetProductByCatIdModel> getProductItemAPI(
      String? catId, String? searchKey) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/products/pos/category-products-all?categoryId=$catId&search=$searchKey',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetProductByCatIdModel getProductByCatIdResponse =
              GetProductByCatIdModel.fromJson(response.data);
          return getProductByCatIdResponse;
        }
      } else {
        return GetProductByCatIdModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
          );
      }
      return GetProductByCatIdModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return GetProductByCatIdModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return GetProductByCatIdModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return GetProductByCatIdModel()..errorResponse = handleError(error);
    }
  }

  /// Table - Fetch API Integration
  Future<GetTableModel> getTableAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/tables',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetTableModel getTableResponse =
              GetTableModel.fromJson(response.data);
          return getTableResponse;
        }
      } else {
        return GetTableModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
          );
      }
      return GetTableModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return GetTableModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return GetTableModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return GetTableModel()..errorResponse = handleError(error);
    }
  }

  /// Shop Details - Fetch API Integration
  Future<GetShopDetailsModel> getShopDetailsAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/shops',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetShopDetailsModel getShopDetailsResponse =
              GetShopDetailsModel.fromJson(response.data);
          return getShopDetailsResponse;
        }
      } else {
        return GetShopDetailsModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
          );
      }
      return GetShopDetailsModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return GetShopDetailsModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return GetShopDetailsModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return GetShopDetailsModel()..errorResponse = handleError(error);
    }
  }

  /// Add to Billing - Post API Integration
  Future<PostAddToBillingModel> postAddToBillingAPI(
      List<Map<String, dynamic>> billingItems) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      final dataMap = {"items": billingItems};
      var data = json.encode(dataMap);
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/billing/calculate',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        try {
          PostAddToBillingModel postAddToBillingResponse =
              PostAddToBillingModel.fromJson(response.data);
          return postAddToBillingResponse;
        } catch (e) {
          return PostAddToBillingModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return PostAddToBillingModel()
          ..errorResponse =
              ErrorResponse(message: "Unexpected error occurred.");
      }
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return PostAddToBillingModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return PostAddToBillingModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return PostAddToBillingModel()..errorResponse = handleError(error);
    }
  }

  /// orderToday - Fetch API Integration
  Future<GetOrderListTodayModel> getOrderTodayAPI(
      String? fromDate, String? toDate) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order?from_date=$fromDate&to_date=$toDate',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetOrderListTodayModel getOrderListTodayResponse =
              GetOrderListTodayModel.fromJson(response.data);
          return getOrderListTodayResponse;
        }
      } else {
        return GetOrderListTodayModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
          );
      }
      return GetOrderListTodayModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return GetOrderListTodayModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return GetOrderListTodayModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return GetOrderListTodayModel()..errorResponse = handleError(error);
    }
  }

  /// Generate Order - Post API Integration
  Future<PostGenerateOrderModel> postGenerateOrderAPI(
      final String orderPayloadJson) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("payload:$orderPayloadJson");
    try {
      var data = orderPayloadJson;
      debugPrint("data:$data");
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        try {
          PostGenerateOrderModel postGenerateOrderResponse =
              PostGenerateOrderModel.fromJson(response.data);
          return postGenerateOrderResponse;
        } catch (e) {
          return PostGenerateOrderModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return PostGenerateOrderModel()
          ..errorResponse =
              ErrorResponse(message: "Unexpected error occurred.");
      }
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return PostGenerateOrderModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return PostGenerateOrderModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return PostGenerateOrderModel()..errorResponse = handleError(error);
    }
  }

  /// Delete Order - Fetch API Integration
  Future<DeleteOrderModel> deleteOrderAPI(String? orderId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order/$orderId',
        options: Options(
          method: 'DELETE',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          DeleteOrderModel deleteOrderResponse =
              DeleteOrderModel.fromJson(response.data);
          return deleteOrderResponse;
        }
      } else {
        return DeleteOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
          );
      }
      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return DeleteOrderModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return DeleteOrderModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return DeleteOrderModel()..errorResponse = handleError(error);
    }
  }

  /// View Order - Fetch API Integration
  Future<GetViewOrderModel> viewOrderAPI(String? orderId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/$orderId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetViewOrderModel getViewOrderResponse =
              GetViewOrderModel.fromJson(response.data);
          return getViewOrderResponse;
        }
      } else {
        return GetViewOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
          );
      }
      return GetViewOrderModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return GetViewOrderModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return GetViewOrderModel()..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return GetViewOrderModel()..errorResponse = handleError(error);
    }
  }

  /// Update Generate Order - Post API Integration
  Future<UpdateGenerateOrderModel> updateGenerateOrderAPI(
      final String orderPayloadJson, String? orderId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("payload:$orderPayloadJson");
    try {
      var data = orderPayloadJson;
      debugPrint("data:$data");
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order/$orderId',
        options: Options(
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        try {
          UpdateGenerateOrderModel updateGenerateOrderResponse =
              UpdateGenerateOrderModel.fromJson(response.data);
          return updateGenerateOrderResponse;
        } catch (e) {
          return UpdateGenerateOrderModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return UpdateGenerateOrderModel()
          ..errorResponse =
              ErrorResponse(message: "Unexpected error occurred.");
      }
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        return UpdateGenerateOrderModel()
          ..errorResponse = ErrorResponse(message: "Invalid Credential");
      } else {
        return UpdateGenerateOrderModel()
          ..errorResponse = handleError(dioError);
      }
    } catch (error) {
      return UpdateGenerateOrderModel()..errorResponse = handleError(error);
    }
  }

  /// handle Error Response
  ErrorResponse handleError(Object error) {
    ErrorResponse errorResponse = ErrorResponse();
    Errors errorDescription = Errors();

    if (error is DioException) {
      DioException dioException = error;

      switch (dioException.type) {
        case DioExceptionType.cancel:
          errorDescription.code = "0";
          errorDescription.message = "Request Cancelled";
          break;

        case DioExceptionType.connectionTimeout:
          errorDescription.code = "522";
          errorDescription.message = "Connection Timeout";
          break;

        case DioExceptionType.sendTimeout:
          errorDescription.code = "408";
          errorDescription.message = "Send Timeout";
          break;

        case DioExceptionType.receiveTimeout:
          errorDescription.code = "408";
          errorDescription.message = "Receive Timeout";
          break;

        case DioExceptionType.badResponse:
          if (dioException.response != null) {
            final statusCode = dioException.response!.statusCode!;
            errorDescription.code = statusCode.toString();

            if (statusCode == 401) {
              errorDescription.message = "Unauthorized: Invalid credentials";
            } else if (statusCode == 500) {
              errorDescription.message = "Internal Server Error";
            } else {
              // fallback to API-provided message
              try {
                final message =
                    dioException.response!.data["errors"][0]["message"];
                errorDescription.message = message ?? "Something went wrong";
              } catch (_) {
                errorDescription.message = "Unexpected error response";
              }
            }
          } else {
            errorDescription.code = "500";
            errorDescription.message = "Internal Server Error";
          }
          break;

        case DioExceptionType.unknown:
          errorDescription.code = "500";
          errorDescription.message = "Unknown error occurred";
          break;

        case DioExceptionType.badCertificate:
          errorDescription.code = "495";
          errorDescription.message = "Bad SSL Certificate";
          break;

        case DioExceptionType.connectionError:
          errorDescription.code = "500";
          errorDescription.message = "Connection error occurred";
          break;
      }
    } else {
      errorDescription.code = "500";
      errorDescription.message = "An unexpected error occurred";
    }

    errorResponse.errors = [errorDescription];
    return errorResponse;
  }
}
