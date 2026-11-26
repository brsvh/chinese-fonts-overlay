# html.pm --- Texinfo HTML customizations for Chinese Fonts Overlay.

use strict;
use warnings;
use utf8;

# Match characters that join across soft line breaks without an intervening
# space: East Asian Fullwidth, Wide, and Halfwidth characters except Hangul
# (following CSS Text Level 3 segment break transformation rules), plus Chinese
# punctuation whose Unicode East Asian Width is Ambiguous.
my $cjk_join_class =
    '\p{East_Asian_Width=F}\p{East_Asian_Width=W}\p{East_Asian_Width=H}'
  . '\x{2014}\x{2018}\x{2019}\x{201C}\x{201D}\x{2026}';
my $cjk_join_char = qr/(?!\p{Script=Hangul})[$cjk_join_class]/;

sub _collapse_cjk_line_breaks
{
  my ($text) = @_;

  $text =~ s/$cjk_join_char\K[ \t]*\r?\n[ \t]*(?=$cjk_join_char)//g;
  return $text;
}

sub _convert_paragraph_cjk
{
  my ($converter, $type, $element, $content) = @_;

  if (   defined($content)
      && !$converter->in_preformatted_context()
      && !$converter->in_verbatim()
      && !$converter->in_raw())
  {
    $content = _collapse_cjk_line_breaks($content);
  }

  return &{$converter->default_type_conversion($type)}
    ($converter, $type, $element, $content);
}

texinfo_register_type_formatting('paragraph', \&_convert_paragraph_cjk);

1;
