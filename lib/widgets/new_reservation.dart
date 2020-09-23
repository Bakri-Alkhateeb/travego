import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travego/providers/places.dart';
import 'package:travego/utils/server_info.dart';

class NewReservation extends StatefulWidget {
  final userId;
  final category;
  final userName;
  final placeName;
  final placeId;

  NewReservation({
    @required this.userId,
    @required this.category,
    @required this.userName,
    @required this.placeName,
    @required this.placeId,
  });

  @override
  _NewReservationState createState() => _NewReservationState();
}

class _NewReservationState extends State<NewReservation> {
  var _height;
  DateTime _chosenDate, _reservationDate;
  TimeOfDay _chosenTime, _reservationTime;
  bool _isReserving = false;

  @override
  void initState() {
    super.initState();
    _chosenDate = DateTime.now();
    _reservationDate = DateTime.now();
    _chosenTime = TimeOfDay.now();
    _reservationTime = TimeOfDay.now();
  }

  _pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().day),
      lastDate: DateTime(DateTime.now().day + 7),
      initialDate: _chosenDate,
    );
    if (date != null)
      setState(() {
        _chosenDate = date;
      });
  }

  _pickTime() async {
    TimeOfDay t =
        await showTimePicker(context: context, initialTime: _chosenTime);
    if (t != null)
      setState(() {
        _chosenTime = t;
      });
  }

  Future<void> _confirmReservation() async {
    try {
      setState(() {
        _isReserving = true;
      });
      print('reserving');
      var response = await http.post(ServerInfo.RESERVATIONS, body: {
        'userId': widget.userId.toString(),
        'category': widget.category,
        'userName': widget.userName,
        'placeName': widget.placeName,
        'placeId': widget.placeId.toString(),
        'chosenTime':
            '${_chosenTime.hourOfPeriod}:${_chosenTime.minute} ${_chosenTime.period.toString().substring(_chosenTime.period.toString().length - 2).toUpperCase()}',
        'chosenDate':
            '${_chosenDate.day}/${_chosenDate.month}/${_chosenDate.year}',
        'reservationTime':
            '${_reservationTime.hourOfPeriod}:${_reservationTime.minute} ${_reservationTime.period.toString().substring(_reservationTime.period.toString().length - 2).toUpperCase()}',
        'reservationDate':
            '${_reservationDate.day}/${_reservationDate.month}/${_reservationDate.year}',
      });
      print('done reserving');
      setState(() {
        _isReserving = false;
      });

      if (response.statusCode == 201) {
        Provider.of<Places>(context, listen: false)
            .fetchPlaces()
            .then((_) => Navigator.of(context).pop());
      } else {
        print("SHIT");
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;

    return _isReserving
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                Text(
                  'اختر وقتاً و تاريخاً',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _height / 36.259740259740259090909090909091,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListTile(
                    subtitle: Text('اضغط هنا لاختيار الوقت'),
                    title: Text(
                      'وقت الحجز',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: _height / 36.259740259740259090909090909091,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      "${_chosenTime.hourOfPeriod}:${_chosenTime.minute} ${_chosenTime.period.toString().substring(_chosenTime.period.toString().length - 2).toUpperCase()}",
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: _height / 36.259740259740259090909090909091,
                      ),
                    ),
                    onTap: _pickTime,
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListTile(
                    subtitle: Text('اضغط هنا لاختيار التاريخ'),
                    title: Text(
                      'تاريخ الحجز',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: _height / 36.259740259740259090909090909091,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      "${_chosenDate.day}/${_chosenDate.month}/${_chosenDate.year}",
                      style: TextStyle(
                        fontSize: _height / 36.259740259740259090909090909091,
                      ),
                    ),
                    onTap: _pickDate,
                  ),
                ),
                Spacer(),
                RaisedButton(
                  onPressed: _confirmReservation,
                  child: Text(
                    'تأكيد الحجز',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _height / 36.259740259740259090909090909091,
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.deepPurple,
                ),
              ],
            ),
          );
  }
}
