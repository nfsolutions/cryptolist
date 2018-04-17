import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'service.dart';

Future<List> getStockRates() async {
  String apiUrl = 'https://ws-api.iextrading.com/1.0/tops';

  // Make a HTTP GET request to the iextrading API.
  // Await basically pauses execution until the get() function returns a Response
  http.Response response = await http.get(apiUrl);

  // Using the JSON class to decode the JSON String
  return JSON.decode(response.body);
}

void main() async {
  // normally we should show a spinner or something else until the data is loaded
  List stockRates = await getStockRates();
  print(stockRates);

  runApp(new MaterialApp(
    home: new StockListWidget(stockRates),
  ));
}

class StockListWidget extends StatelessWidget {
  // This is a list of material colors. Feel free to add more colors, it won't break the code
  final List<MaterialColor> _colors = [Colors.blue, Colors.indigo, Colors.red];

  // t_ means private variable
  final List _stocks;

  // constructor, the variable gets assigned to the private variable _stocks
  StockListWidget(this._stocks);

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      body: _buildBody(),
      backgroundColor: Colors.blue,
    );
  }

  Widget _buildBody() {
    return new Container(
      // margins, top, left, right and bottom.
      margin: const EdgeInsets.fromLTRB(8.0, 56.0, 8.0, 0.0),
      child: new Column(
        // A column widget can have several widgets that are placed in a top down fashion
        children: <Widget>[_getAppTitleWidget(), _getListViewWidget()],
      ),
    );
  }

  Widget _getAppTitleWidget() {
    return new Text(
      'Stock Quotes',
      style: new TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.0),
    );
  }

  Widget _getListViewWidget() {
    // We want the ListView to have the flexibility to expand to fill the
    // available space in the vertical axis
    return new Flexible(
        child: new ListView.builder(
            // The number of items to show
            itemCount: _stocks.length,
            // Callback that should return ListView children
            // The index parameter = 0...(itemCount-1)
            itemBuilder: (context, index) {
              // Get the stocks at this position
              final Map stock = _stocks[index];

              // Get the icon color. Since x mod y, will always be less than y,
              // this will be within bounds
              final MaterialColor color = _colors[index % _colors.length];

              return _getListItemWidget(stock, color);
            }));
  }

  CircleAvatar _getLeadingWidget(String stockSymbol, MaterialColor color) {
    return new CircleAvatar(
      backgroundColor: color,
      child: new Text(stockSymbol[0]),
    );
  }

  Text _getTitleWidget(String stockSymbol) {
    return new Text(
      stockSymbol,
      style: new TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Text _getSubtitleWidget(String price, String volume) {
    String title = price + ' USD ' + volume;
    //return new Text('\$$priceUsd\n1 hour: $percentChange1h%');
    return new Text(title);
  }

  ListTile _getListTile(Map stock, MaterialColor color) {
    double lastSalePrice = stock['lastSalePrice'];
    int volume = stock['volume'];

    return new ListTile(
      leading: _getLeadingWidget(stock['symbol'], color),
      title: _getTitleWidget(stock['symbol']),
      subtitle: _getSubtitleWidget(
          'Price:' + lastSalePrice.toString(), 'Volume:' + volume.toString()),
      isThreeLine: true,
    );
  }

  Container _getListItemWidget(Map stock, MaterialColor color) {
    // Returns a container widget that has a card child and a top margin of 5.0
    return new Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: new Card(
        child: _getListTile(stock, color),
      ),
    );
  }
}
