import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class FoodCategoryEvent {}

class FoodCategory extends FoodCategoryEvent {}

class FoodProductItem extends FoodCategoryEvent {
  String catId;
  String searchKey;
  FoodProductItem(this.catId, this.searchKey);
}

class AddToBilling extends FoodCategoryEvent {
  List<Map<String, dynamic>> billingItems;
  AddToBilling(this.billingItems);
}

class FoodCategoryBloc extends Bloc<FoodCategoryEvent, dynamic> {
  FoodCategoryBloc() : super(dynamic) {
    on<FoodCategory>((event, emit) async {
      await ApiProvider().getCategoryAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<FoodProductItem>((event, emit) async {
      await ApiProvider()
          .getProductItemAPI(event.catId, event.searchKey)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<AddToBilling>((event, emit) async {
      await ApiProvider().postAddToBillingAPI(event.billingItems).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
  }
}
