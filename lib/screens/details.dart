import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travego/providers/auth.dart';
import 'package:travego/providers/places.dart';
import 'package:travego/widgets/new_reservation.dart';

import '../models/place.dart';
import '../utils/server_info.dart';

class DetailsScreen extends StatefulWidget {
  static const routeName = '/details';

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  var _height;
  var _id, _category;
  Place _place;
  bool _firstTime = true;
  bool _isLoading = true;
  String _imageFolderURL;

  @override
  void didChangeDependencies() {
    if (_firstTime) {
      final _args =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      _id = _args['id'];
      _category = _args['category'];
      _imageFolderURL = _category == 'Hotels'
          ? ServerInfo.HOTELS_IMAGES
          : _category == 'Cafes'
              ? ServerInfo.CAFES_IMAGES
              : ServerInfo.RESTAURANTS_IMAGES;
      _firstTime = false;
      _isLoading = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _place = Provider.of<Places>(context).placeDetails(_id, _category);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _place.places > 0
            ? showModalBottomSheet(
                context: context,
                builder: (_) {
                  return GestureDetector(
                    onTap: () {},
                    child: NewReservation(
                      userId: Provider.of<Auth>(context, listen: false).userId,
                      category: _category,
                      placeName: _place.name,
                      placeId: _id,
                      userName:
                          Provider.of<Auth>(context, listen: false).fullName,
                    ),
                    behavior: HitTestBehavior.opaque,
                  );
                },
              )
            : null,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      child: FadeInImage(
                        placeholder: AssetImage('assets/loading.gif'),
                        image: NetworkImage(
                          '$_imageFolderURL${_place.image}',
                        ),
                        fit: BoxFit.fitHeight,
                        height: 350,
                        width: double.infinity,
                      ),
                      height: 350,
                      width: double.infinity,
                    ),
                    Positioned(
                      top: 50,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 270, left: 10.0, right: 10.0),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 20),
                    width: double.infinity,
                    height: _height / 1.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          _place.name,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: _height / 31.908571428571428,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                CircleAvatar(
                                  child: Icon(
                                    _category == 'Hotel'
                                        ? Icons.hotel
                                        : Icons.table_chart,
                                    size: _height / 26.59047619047619,
                                  ),
                                  radius: _height / 26.59047619047619,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Consumer<Places>(
                                  builder: (ctx, place, _) => Text(
                                    _place.places.toString(),
                                    style: TextStyle(
                                      fontSize: _height /
                                          36.259740259740259090909090909091,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                CircleAvatar(
                                  child: Icon(
                                    Icons.star_border,
                                    size: _height / 26.59047619047619,
                                  ),
                                  radius: _height / 26.59047619047619,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  _place.rate.toString(),
                                  style: TextStyle(
                                    fontSize: _height /
                                        36.259740259740259090909090909091,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                CircleAvatar(
                                  child: Icon(
                                    Icons.attach_money,
                                    size: _height / 26.59047619047619,
                                  ),
                                  radius: _height / 26.59047619047619,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  _place.price.toString(),
                                  style: TextStyle(
                                    fontSize: _height /
                                        36.259740259740259090909090909091,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: <Widget>[
                            Text(
                              'الوصف',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize:
                                    _height / 36.259740259740259090909090909091,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          child: Container(
                            child: Text(
                              _place.description,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: _height / 39.885714285714285,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
