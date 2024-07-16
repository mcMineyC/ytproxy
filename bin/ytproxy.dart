import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main(List<String> arguments) async {
  YoutubeExplode yt = YoutubeExplode();
  var app = Router();

  app.get('/hello', (Request request) {
    return Response.ok('hello-world');
  });

  app.get('/url/<id>', (Request request, String id) async {
    // print('url id: $id');
    var media = await yt.videos.streamsClient.getManifest(id);
    var streamInfo = media.audioOnly.withHighestBitrate();
    // print('url: ${streamInfo.url.toString()}');
    return Response.ok(streamInfo.url.toString());
  });
  app.get('/url/ios/<id>', (Request request, String id) async {
    // print('url id: $id');
    var media = await yt.videos.streamsClient.getManifest(id);
    var streamInfo = media.audioOnly.where((e) => e.audioCodec != 'opus' && e.container != StreamContainer.webM).withHighestBitrate();
    // print('url: ${streamInfo.url.toString()}');
    return Response.ok(streamInfo.url.toString());
  });
  var handler = const Pipeline()
    .addMiddleware(logRequests())
    .addMiddleware(corsHeaders(originChecker: (origin) {
      if(origin.contains('localhost')) return true;
      else if(origin.contains('eatthecow.mooo.com')) return true;
      else if(origin.contains('taxi-native.vercel.app')) return true;
      else return false;
    }))
    .addHandler(app);
  var server = await io.serve(handler, '0.0.0.0', 8080);
  print("Server running at http://${server.address.host}:${server.port}");
}
