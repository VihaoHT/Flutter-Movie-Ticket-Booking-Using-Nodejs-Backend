import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_booking_app/admin/cinema/cinema_bloc/cinema_bloc.dart';
import 'package:movie_booking_app/admin/cinema/screens/add_new_cinema.dart';
import 'package:movie_booking_app/models/cinema_model.dart';
import 'package:get/get.dart' as Getx;
import '../../../core/components/header_admin.dart';
import '../../../core/constants/constants.dart';
import '../../../core/constants/ultis.dart';

class CinemaAdminScreen extends StatelessWidget {
  const CinemaAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            const HeaderAdmin(title: "Cinema Manager"),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  splashColor: Colors.red,
                  hoverColor: Colors.white54,
                  onTap: () {
                    Getx.Get.to(() => (const AddNewCinema()),
                        transition: Getx.Transition.cupertino,
                        duration: const Duration(seconds: 2));
                  },
                  child: Container(
                    width: 195,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Constants.bgColorAdmin,
                    ),
                    child: const ListTile(
                      title: Text(
                        "Add new Cinema",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: 500,
                    color: Constants.bgColorAdmin,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) async {
                        if (context.mounted) {
                          context
                              .read<CinemaBloc>()
                              .add(LoadSearchCinemaEvent(name: value));
                        }
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Write the cinema name u wanna find",
                        labelStyle: const TextStyle(color: Colors.white),
                        suffix: InkWell(
                            onTap: () {
                              searchController.clear();
                              context
                                  .read<CinemaBloc>()
                                  .add(const LoadSearchCinemaEvent(name: ""));
                            },
                            child: const Icon(
                              Icons.clear,
                              color: Colors.red,
                            )),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _cinemaListBuilder(),
          ],
        ),
      ),
    ));
  }

  BlocConsumer<CinemaBloc, CinemaState> _cinemaListBuilder() {
    return BlocConsumer<CinemaBloc, CinemaState>(
            listener: (context, state) {
              if (state is CinemaErrorState) {
                showToastFailed(
                    context, "Failed to load data ${state.error.toString()}");
                Text(
                  state.error.toString(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }
            },
            builder: (context, state) {
              if (state is CinemaLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CinemaLoadedState) {
                List<Cinema> cinemaList = state.cinema;
                return Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: cinemaList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Constants.bgColorAdmin,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text(
                                          "Cinema ID  :",
                                          style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Text(
                                        cinemaList[index].id.toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          child: InkWell(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: cinemaList[index]
                                                      .id
                                                      .toString()));
                                              showToastSuccess(context, "Copied");
                                            },
                                            child: Image.asset(
                                                Constants.copyPath,color: Colors.white,),
                                          )),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text(
                                          "Cinema name :",
                                          style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Text(
                                        cinemaList[index].name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text(
                                          "Address  :",
                                          style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 900,
                                        child: Text(
                                          cinemaList[index].location.address,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              overflow: TextOverflow.clip,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                width: 100,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.red,
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Getx.Get.defaultDialog(
                                      title: "DELETE THE CINEMA!",
                                      titleStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      middleText:
                                          "Are you sure you want to delete this cinema? After delete you cannot undo",
                                      onCancel: () {
                                        // do nothing
                                      },
                                      onConfirm: () {
                                        Navigator.pop(context);
                                        context.read<CinemaBloc>().add(
                                              DeleteCinemaEvent(
                                                  cinemaId:
                                                      cinemaList[index].id,
                                                  context: context),
                                            );
                                      },
                                      middleTextStyle: const TextStyle(
                                          color: Constants.colorTitle,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    );
                                  },
                                  title: const Text(
                                    "Delete",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          );
  }
}
