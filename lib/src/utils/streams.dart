import 'package:stream_transform/stream_transform.dart';

Stream<Iterable<T>> combineIterableOfStreams<T>(Iterable<Stream<T>> streams) {
  if(streams.isEmpty) {
    return Stream<List<T>>.value(<T>[]);
  } else {
    return streams.first.combineLatestAll(streams.skip(1));
  }
}

Stream<List<T>> combineListOfStreams<T>(List<Stream<T>> streams) {
  if(streams.isEmpty) {
    return Stream<List<T>>.value(<T>[]);
  } else {
    return streams.first.combineLatestAll(streams.skip(1));
  }
}
