# LineNumbering

<div>
    How to build:
    <li>ghc -o main Main.hs</li>
    <li>stack build --fast (This will download the required packages)</li>
</div>

<div class="row"><div class="col-md-12"><h2>Leírás</h2><div style="margin-left:0px; background: lightgray"><ol style="list-style-type: upper-alpha">
<li><p>Készíts egy programot, ami egy Pandoc markdown formátumú dokumentumban beszámozza a kód blokkok sorait.</p>
<p>Például, ha a bemenet</p>
<pre><code>szöveg

    kód

szöveg

    f :: a -&gt; a
    f x = x</code></pre>
<p>akkor a kimenet legyen</p>
<pre><code>szöveg

    1   kód

szöveg

    1   f :: a -&gt; a
    2   f x = x</code></pre>
<p>Az egyszerűség kedvéért legyen minden sorszám után 3 db szóköz karakter.</p></li>
<li><p>Az egymás utáni kód blokkokban folytatódjon a számozás, ne mindig 1-től kezdje:</p>
<pre><code>szöveg

    1   kód

szöveg

    2   f :: a -&gt; a
    3   f x = x</code></pre></li>
<li><p>Adja vissza a program, hogy hány sorszámot osztott ki</p></li>
<li><p>Adja vissza a program, hogy hány kód blokk volt</p></li>
<li><p>Adja vissza a program, hogy hány karakter volt a dokumentumban (az <code>Str</code> elemek karaktereit számolja a Pandoc adatszerkezetében)</p></li>
<li><p>Adja vissza a program, hogy hány szó volt a dokumentumban (az <code>Str</code> elemeket számolja a Pandoc adatszerkezetében).</p></li>
<li><p>Lehetőleg egy menetben készítse el a program az E-F statisztikákat (opcionális).</p></li>
</ol>
<p>Megjegyzések:</p>
<ul>
<li>Nincs automatikus tesztelés</li>
<li>A megoldások mellett megjegyzésben írd le hogy mi működik, mi nem működik, hogyan kell a programot tesztelni, és hogy milyen egyéni döntéseket hoztál, amik befolyásolják a program működését</li>
<li>A jegyzet elérhető a tárgy honlapján: <a href="http://people.inf.elte.hu/divip/" class="uri">http://people.inf.elte.hu/divip/</a><br>
A jegyzet hetente frissül, jövő hétfőn több kiegészítés várható ami hasznos lehet a beadandó elkészítéséhez</li>
</ul>
<p><strong>Kiegészítések, március 21. 14:15</strong></p>
<ul>
<li>Elég egy programot beadni, ami megvalósítja az A-G) feladatokat. Ez a programot lehet egy Haskell fájlban implementálni.</li>
<li>A megfelelő eszközöket használva a feladat megoldható &lt;100 programsorral. Ezek az eszközök: <code>Text.Pandoc.Walk</code>, <code>State</code> monád, <code>Sum</code> monoid (Ezekről szó volt a hétfői előadáson, a következő hétfőn a jegyzetbe is be fog kerülni.)</li>
<li>A zh egy ehhez hasonló feladat lesz, ahol lehet használni a beadandó kódját.</li>
<li>Rövidesen elérhetővé teszek egy konkrét bemenet-kimenet tesztet.</li>
</ul>
<p><strong>Kiegészítések, március 21. 17:15</strong></p>
<ul>
<li>A részfeladatok pontosítása, példa megváltoztatása</li>
<li>Segítség:
<ul>
<li>a <code>ReaderOptions</code> értéke legyen <code>def {readerExtensions = pandocExtensions}</code><br>
</li>
<li>a <code>WriterOptions</code> értéke legyen <code>def {writerExtensions = pandocExtensions}</code><br>
</li>
</ul></li>
<li><p>Teszt bemenet: <a href="http://people.inf.elte.hu/divip/example.md" class="uri">http://people.inf.elte.hu/divip/example.md</a><br>
Teszt kimenet: <a href="http://people.inf.elte.hu/divip/example_out.md" class="uri">http://people.inf.elte.hu/divip/example_out.md</a></p>
<p>Közben ezt írja ki a program a konzolra:</p>
<pre><code>195 code blocks
762 code lines
18728 words (without code)
90075 characters (without code)</code></pre></li>
</ul></div></div></div>
