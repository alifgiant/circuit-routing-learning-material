import 'package:simulasi_routing/algo/model.dart';

// STO Data
final pnk = Sto('Pnk', const Point(5, 7, 5.0));
final mat = Sto('Mat', const Point(7, 4, 5.0));
final bal = Sto('Bal', const Point(1, 3, 5.0));
final ant = Sto('Ant', const Point(3, 10, 5.0));
final sug = Sto('Sug', const Point(8, 12, 5.0));
final tka = Sto('Tka', const Point(9, 0, 5.0));
final mal = Sto('Mal', const Point(10, 18, 5.0));
final tma = Sto('Tma', const Point(1, 10, 5.0));
final kim = Sto('Kim', const Point(0, 16, 5.0));
final sud = Sto('Sud', const Point(2, 18, 5.0));
final mar = Sto('Mar', const Point(5, 23, 5.0));

final stoNameMap = {
  pnk.name: pnk,
  mat.name: mat,
  bal.name: bal,
  ant.name: ant,
  sug.name: sug,
  tka.name: tka,
  mal.name: mal,
  tma.name: tma,
  kim.name: kim,
  sud.name: sud,
  mar.name: mar,
};

final connections = {
  Path(pnk, bal),
  Path(bal, mat),
  Path(mat, tka),
  Path(mat, sug),
  Path(sug, mal),
  Path(mal, ant),
  Path(ant, pnk),
  Path(ant, sug),
  Path(pnk, tma),
  Path(pnk, mat),
  Path(tma, ant),
  Path(ant, kim),
  Path(kim, tma),
  Path(kim, sud),
  Path(sud, mar),
  Path(pnk, sug),
};
