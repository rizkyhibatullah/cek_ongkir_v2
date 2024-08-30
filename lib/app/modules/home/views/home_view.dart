import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ongkos_kirim_v2/app/modules/home/data/model/city_model.dart';
import 'package:ongkos_kirim_v2/app/modules/home/data/model/province_model.dart';

import '../controllers/home_controller.dart';

import 'package:http/http.dart' as http;

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Provinsi(),
          Obx(() => controller.hiddenKota.isTrue
              ? SizedBox()
              : Kota(
                  provId: controller.provId.value,
                )),
        ],
      ),
    );
  }
}

class Provinsi extends GetView<HomeController> {
  const Provinsi({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownSearch<Province>(
        clearButtonProps:
            ClearButtonProps(icon: Icon(Icons.clear), isVisible: true),
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Cari Provinsi",
              hintStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
          ),
          itemBuilder: (context, item, isSelected) => Container(
            padding: EdgeInsets.all(10),
            child: Text(
              "${item.province}",
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w300),
            ),
          ),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            label: Text("Provinsi"),
          ),
        ),
        asyncItems: (String filter) async {
          try {
            var response = await http.get(
              Uri.parse("https://api.rajaongkir.com/starter/province"),
              headers: {"key": "78b30bfd2f04b4d513bf24300a580439"},
            );

            var data = jsonDecode(response.body) as Map<String, dynamic>;
            var listAllProvince =
                data["rajaongkir"]["results"] as List<dynamic>;
            var statusCode = data["rajaongkir"]["status"]["code"];

            if (statusCode != 200) {
              throw "error";
            }
            var models = Province.fromJsonList(listAllProvince);
            return models;
          } catch (e) {
            print(e);
            return List<Province>.empty();
          }
        },
        onChanged: (provValue) {
          if (provValue != null) {
            controller.hiddenKota.value = false;
            controller.provId.value = int.parse(provValue.provinceId);
          } else {
            controller.hiddenKota.value = true;
            controller.provId.value = 0;
          }
        },
        itemAsString: (item) {
          return item.province;
        },
      ),
    );
  }
}

class Kota extends GetView<HomeController> {
  const Kota({
    required this.provId,
    super.key,
  });

  final int provId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownSearch<City>(
        clearButtonProps: ClearButtonProps(
          icon: Icon(Icons.clear),
          isVisible: true,
        ),
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Cari Kota",
              hintStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
          ),
          itemBuilder: (context, item, isSelected) => Container(
            padding: EdgeInsets.all(10),
            child: Text(
              "${item.type} ${item.cityName}",
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w300),
            ),
          ),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            label: Text("Kota"),
          ),
        ),
        asyncItems: (String filter) async {
          try {
            var response = await http.get(
              Uri.parse(
                  "https://api.rajaongkir.com/starter/city?province=$provId"),
              headers: {"key": "78b30bfd2f04b4d513bf24300a580439"},
            );

            var data = jsonDecode(response.body) as Map<String, dynamic>;
            var listAllCity = data["rajaongkir"]["results"] as List<dynamic>;
            var statusCode = data["rajaongkir"]["status"]["code"];

            if (statusCode != 200) {
              throw "error";
            }
            var models = City.fromJsonList(listAllCity);
            return models;
          } catch (e) {
            print(e);
            return List<City>.empty();
          }
        },
        onChanged: (cityValue) {
          if (cityValue != null) {
            print(cityValue.cityName);
          } else {
            print("Tidak Memilihi Kota");
          }
        },
        itemAsString: (item) {
          return "${item.type} ${item.cityName}";
        },
      ),
    );
  }
}
