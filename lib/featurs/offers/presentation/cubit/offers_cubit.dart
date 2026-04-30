import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/featurs/offers/domain/entities/fer_entity.dart';
import '../../domain/repos/offers_repo.dart';

abstract class OffersState {}
class OffersInitial extends OffersState {}
class OffersLoading extends OffersState {}
class OffersLoaded extends OffersState { final List<OfferEntity> offers; OffersLoaded(this.offers); }
class OffersError extends OffersState { final String message; OffersError(this.message); }

class OffersCubit extends Cubit<OffersState> {
  final OffersRepo offersRepo;
  StreamSubscription? _subscription;

  OffersCubit(this.offersRepo) : super(OffersInitial());

  void fetchOffers(String pharmacyId) {
    emit(OffersLoading());
    _subscription?.cancel();
    _subscription = offersRepo.getOffersStream(pharmacyId).listen(
      (offers) => emit(OffersLoaded(offers)),
      onError: (e) => emit(OffersError(e.toString())),
    );
  }

  Future<void> createOffer(OfferEntity offer) async {
    try {
      await offersRepo.addOffer(offer);
    } catch (e) {
      emit(OffersError("فشل إضافة العرض"));
    }
  }

  Future<void> removeOffer(String id) async {
    try {
      await offersRepo.deleteOffer(id);
    } catch (e) {
      emit(OffersError("فشل الحذف"));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}