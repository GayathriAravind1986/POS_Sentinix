import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class OrderTodayEvent {}

class OrderTodayList extends OrderTodayEvent {
  String fromDate;
  String toDate;
  OrderTodayList(this.fromDate, this.toDate);
}

// class AddToBilling extends OrderTodayEvent {
//   List<Map<String, dynamic>> billingItems;
//   AddToBilling(this.billingItems);
// }

class OrderTodayBloc extends Bloc<OrderTodayEvent, dynamic> {
  OrderTodayBloc() : super(dynamic) {
    on<OrderTodayList>((event, emit) async {
      await ApiProvider()
          .getOrderTodayAPI(event.fromDate, event.toDate)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    // on<AddToBilling>((event, emit) async {
    //   await ApiProvider().postAddToBillingAPI(event.billingItems).then((value) {
    //     emit(value);
    //   }).catchError((error) {
    //     emit(error);
    //   });
    // });
  }
}
