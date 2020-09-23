import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travego/utils/server_info.dart';

import '../models/place.dart';

class Places with ChangeNotifier {
  List<Place> _restaurants = [];
  List<Place> _hotels = [];
  List<Place> _cafes = [];
  List<Place> _places = [];

  List<Place> get places {
    _places.addAll(_hotels);
    _places.addAll(_restaurants);
    _places.addAll(_cafes);
    return [..._places];
  }

  Future<void> _fetchRestaurants() async {
    try {
      final response = await http.get(ServerInfo.RESTAURANTS);
      final responseData = json.decode(response.body)['restaurants'];
      if (responseData == null) {
        return;
      }

      final List<Place> loadedRestaurants = [];
      responseData.forEach((restaurant) {
        loadedRestaurants.add(
          Place(
              id: restaurant['id'],
              name: restaurant['name'],
              rate: restaurant['rate'],
              latitude: restaurant['latitude'],
              longitude: restaurant['longitude'],
              image: restaurant['image'],
              description: restaurant['description'],
              places: restaurant['places'],
              price: restaurant['price'],
              category: 'Restaurants'),
        );
      });
      _restaurants = loadedRestaurants;
    } catch (error) {
      throw (error);
    }
  }

  Future<void> _fetchHotels() async {
    try {
      final response = await http.get(ServerInfo.HOTELS);
      final responseData = json.decode(response.body)['hotels'];
      if (responseData == null) {
        return;
      }

      final List<Place> loadedHotels = [];
      responseData.forEach((hotel) {
        loadedHotels.add(
          Place(
              id: hotel['id'],
              name: hotel['name'],
              rate: hotel['rate'],
              latitude: hotel['latitude'],
              longitude: hotel['longitude'],
              image: hotel['image'],
              description: hotel['description'],
              places: hotel['places'],
              price: hotel['price'],
              category: 'Hotels'),
        );
      });
      _hotels = loadedHotels;
    } catch (error) {
      throw (error);
    }
  }

  Future<void> _fetchCafes() async {
    try {
      final response = await http.get(ServerInfo.CAFES);
      final responseData = json.decode(response.body)['cafes'];
      if (responseData == null) {
        return;
      }

      final List<Place> loadedCafes = [];
      responseData.forEach((cafe) {
        loadedCafes.add(
          Place(
              id: cafe['id'],
              name: cafe['name'],
              rate: cafe['rate'],
              latitude: cafe['latitude'],
              longitude: cafe['longitude'],
              image: cafe['image'],
              description: cafe['description'],
              places: cafe['places'],
              price: cafe['price'],
              category: 'Cafes'),
        );
      });
      _cafes = loadedCafes;
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchPlaces() async {
    try {
      await _fetchHotels();
      await _fetchRestaurants();
      await _fetchCafes();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Place _restaurantDetails(int id) {
    return _restaurants.firstWhere((restaurant) => restaurant.id == id);
  }

  Place _cafeDetails(int id) {
    return _cafes.firstWhere((cafe) => cafe.id == id);
  }

  Place _hotelDetails(int id) {
    return _hotels.firstWhere((hotel) => hotel.id == id);
  }

  Place placeDetails(int id, String category) {
    if (category == 'Hotels')
      return _hotelDetails(id);
    else if (category == 'Cafes')
      return _cafeDetails(id);
    else
      return _restaurantDetails(id);
  }
}
