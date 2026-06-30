{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-comic-sans-ms";
  fontFamily = "Comic Sans MS";

  files = [
    "comic.ttf"
    "comicbd.ttf"
    "comici.ttf"
    "comicz.ttf"
  ];
}
