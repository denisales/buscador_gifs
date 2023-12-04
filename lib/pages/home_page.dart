import 'dart:convert';
import 'package:buscador_gifs/pages/gif_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = '';
  int _offset = 0;
  static const String _apiKey = "b8Yrfj9zvWjgimV0KtOWKtDaEu0u7iU1";
  final textController = TextEditingController();

  Future<Map> _getGifs() async {
    // ignore: unused_local_variable
    http.Response response;

    if (_search.isEmpty) {
      Uri url = Uri.https('api.giphy.com', '/v1/gifs/trending', {
        'api_key': _apiKey,
        'limit': '20',
        'rating': 'g',
        'offset': '$_offset',
      });
      response = await http.get(url);
    } else {
      Uri url = Uri.https('api.giphy.com', '/v1/gifs/search', {
        'api_key': _apiKey,
        'limit': '19',
        'offset': '$_offset',
        'q': _search,
      });
      response = await http.get(url);
    }

    return json.decode(response.body);
  }

  int _getCount(List data) {
    if (_search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (_search.isEmpty || index < snapshot.data["data"].length) {
          return GestureDetector(
            child: Container(
              color: Colors.grey[900],
              child: Hero(
                tag: snapshot.data['data'][index]["id"],
                child: CachedNetworkImage(
                  imageUrl: snapshot.data['data'][index]['images']
                      ['fixed_height']['url'],
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  height: 300,
                  width: 300,
                  maxHeightDiskCache: 150,
                  maxWidthDiskCache: 150,
                  progressIndicatorBuilder: (context, url, downloadProgress) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.grey[500],
                        value: downloadProgress.progress,
                      ),
                    );
                  },
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GifPage(gifData: snapshot.data['data'][index]),
                ),
              );
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
          );
        } else {
          return GestureDetector(
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  "Carregar mais...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Giphy_Logo_9.2016.svg/400px-Giphy_Logo_9.2016.svg.png',
          height: 50,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: textController,
              onSubmitted: (value) {
                setState(() {
                  _search = value;
                  _offset = 0;
                });
              },
              cursorColor: Colors.white,
              decoration: InputDecoration(
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _search = '';
                            _offset = 0;
                            textController.text = '';
                          });
                        },
                      )
                    : null,
                labelText: 'Pesquise aqui!',
                labelStyle: const TextStyle(
                  color: Colors.white,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.white,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.white,
                  ),
                ),
                hintStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
