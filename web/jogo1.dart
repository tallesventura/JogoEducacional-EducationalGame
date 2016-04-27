import 'dart:html';
import 'dart:math';
import 'package:gorgon/gorgon.dart';
import 'package:css_animation/css_animation.dart';
import 'dart:convert' show JSON;
import 'dart:async' show Future;

List<String> texto_botao=[];
List<String> valor_botao=[];
List<String> style_botao=[];
List<String> fases_jogo=[];
int i,corretos,fase_atual,vidas;
const maximoFases=11;
Sound backgoundsound, correctSound, errorSound, gameoverSound;
Element tresVidas, fazenda;
ButtonElement iniciar, iniciar2,continuar, tentarNovamente, jogarNovamente, botao_0, botao_1, botao_2;
DivElement frases, botoes,balao,balao2,imgvidas, instru;
ImageElement srpedro, animais;

//ler dados do JSON
class Leitura{
  static Future lendoDados(){
    var path = 'jogo1.json';
    return HttpRequest.getString(path).then(_dadosFromJson);
  }
  static _dadosFromJson(String jsonString){
    Map dados = JSON.decode(jsonString);
    texto_botao=dados['texto_botao'];
    valor_botao=dados['valor_botao'];
    style_botao=dados['style_botao'];
    fases_jogo=dados['fases_jogo'];
  }
  static Future leSons(){
    backgoundsound = new Sound( soundUrl: "./resources/music/somjogo.wav" );
    correctSound = new Sound( soundUrl: "./resources/music/correct.wav" );
    //errorSound = new Sound( soundUrl: "./resources/music/error.wav" );
    gameoverSound = new Sound( soundUrl: "./resources/music/gameover.wav" );
    
    srpedro = new ImageElement(src:"./resources/images/srpedro.png")  ..id="srpedro";
    srpedro = new ImageElement(src:"./resources/images/srpedrofrases.png")  ..id="srpedrofrases";
    animais = new ImageElement(src: "./resources/images/animaisfases.png") ..id="animais";  
    srpedro = new ImageElement(src:"./resources/images/mulhererrou.png")  ..id="srpedrofrases";
    
    return Future.wait([backgoundsound.onLoad, correctSound.onLoad, gameoverSound.onLoad,
                        srpedro.onLoad.first, animais.onLoad.first]);
  }
}

void main() {
  Future.wait([Leitura.leSons(),Leitura.lendoDados()]).then((_){
    backgoundsound.play( looping: true );
    querySelector('#loading').style.display = 'none';
    paginaInicial();
  });
}

void paginaInicial(){
  tentarNovamente = new ButtonElement() ..id="tentar";
  jogarNovamente = new ButtonElement() ..id="jogarNovamente";
  iniciar = new ButtonElement();
  iniciar..id = 'iniciar';
  querySelector('#jogo_todo').style.display = 'block';
  ImageElement fazenda = new ImageElement(src:"./resources/images/afazenda.png") ..id="fazenda";
  srpedro = new ImageElement(src:"./resources/images/srpedro.png")  ..id="srpedro";
  querySelector('#tela_jogo').children.add(fazenda);
  iniciar.onClick.listen((event)=>instrucoes());
  var animation = new CssAnimation('opacity', 0, 1);
  animation.apply(querySelector('#fazenda'));
  querySelector('#tela_jogo').children.add(srpedro);
  animation.apply(querySelector('#srpedro'));
  querySelector('#tela_jogo').children.add(iniciar);
  animation.apply(querySelector('#iniciar'));
}

void instrucoes(){
  iniciar.remove();
  srpedro.remove();
  srpedro = new ImageElement(src:"./resources/images/srpedrofrases.png")  ..id="srpedrofrases";
  querySelector('#tela_jogo').children.add(srpedro);
  balao2 = new DivElement() ..id="balao2" ..className="balao2"; 
  querySelector('#tela_jogo').children.add(balao2);
  instru = new DivElement() ..id="instru";
  instru.text = '''Hello, my name is Pedro. I am the owner of a really big farm. 
I live with my wife and I have a lot of animals. 
As the time passed, my animals procreated a lot and the money I had to buy them food was not enough anymore.
But then I saw an area full of bushes and I came up with a great ideia:
- I will plant the food to feed my animals on that area! By doing so, all of them will be fed and maybe I can even sell some vegetables. 
I have made my mind! I will plant kale, lettuce, corn and carrots on that area to feed my animals. I will also plant watermelons, because I love watermelon!
Let's go, help me on this task!
Click on the arrow to begin.''';
  balao2.children.add(instru);
  continuar = new ButtonElement() ..id="continuar";
  querySelector('#tela_jogo').children.add(continuar);
  continuar.onClick.listen((event)=>play());
}

void pegaDados(){}

void play(){
  continuar.remove();
  balao2.remove();
  instru.remove();
  imgvidas = new DivElement() ..id="vidas";
  animais = new ImageElement(src: "./resources/images/animaisfases.png") ..id="animais";  
  balao = new DivElement() ..id="balao" ..className="balao"; 
  querySelector('#tela_jogo').children.add(imgvidas);
  i=0;corretos=0;fase_atual=0;vidas=3;
  frases = new DivElement() ..id="frases";
  balao.children.add(frases);
  botoes = new DivElement() ..id="botoes";
  querySelector('#tela_jogo').children.add(botoes);
  querySelector('#tela_jogo').children.add(balao);
  querySelector('#tela_jogo').children.add(animais);
  botao_0 = new ButtonElement();
  botao_1 = new ButtonElement();
  botao_2 = new ButtonElement();
  querySelector('#botoes').children.add(botao_0);
  querySelector('#botoes').children.add(botao_1);
  querySelector('#botoes').children.add(botao_2);
  geraPagina();
}

void mostraBotao(int j,int n){
  if(j==0){
    botao_0..text = texto_botao[n]
             ..style.display = style_botao[n]
             ..value=valor_botao[n]
             ..onClick.listen(valor);
  }
  if(j==1){
      botao_1..text = texto_botao[n]
               ..style.display = style_botao[n]
               ..value=valor_botao[n]
               ..onClick.listen(valor);
    }
  if(j==2){
      botao_2..text = texto_botao[n]
               ..style.display = style_botao[n]
               ..value=valor_botao[n]
               ..onClick.listen(valor);
    }
}

void geraPagina(){
  defineVidas();
  int k=0,n,j=-1;
  var num = new Random();
  List<int> sorteados=[];
  if(fase_atual < maximoFases){
    frases.text = fases_jogo[fase_atual];
    while(k<3){
      n=num.nextInt(3);
      if(!sorteados.contains(n)){
        j++;
        mostraBotao(j,n+i);
        sorteados.add(n);
        k++;
      }
    }
  }
}

void defineVidas(){
  if(vidas == 3)
    querySelector('#vidas').style.backgroundImage = 'url("./resources/images/tresvidas.png")';
  if(vidas == 2)
    querySelector('#vidas').style.backgroundImage = 'url("./resources/images/duasvidas.png")';
  if(vidas == 1)
    querySelector('#vidas').style.backgroundImage = 'url("./resources/images/umavida.png")';
  if(vidas == 0)
    querySelector("#vidas").style.display='none';
}

void geraPaginaFinal(Event e){
  defineVidas();
  botoes.remove();
  frases.text = "Very well! You won! Thanks for helping me to take care of my farm!";
  querySelector('#tela_jogo').children.add(jogarNovamente);
  jogarNovamente.onClick.listen((event)=>novamente());
}

void gameOverPage(){
  imgvidas.remove();
  botoes.remove();
  //frases.text = "You lost!";
  querySelector('#tela_jogo').children.add(tentarNovamente);
  tentarNovamente.onClick.listen((event)=>novamente());
}
void novamente(){
  balao.remove();
  frases.remove();
  tentarNovamente.remove();
  jogarNovamente.remove();
  imgvidas.remove();
  srpedro.remove();
  animais.remove();
  paginaInicial();
}

void valor(Event e){
  String valor = (e.target as ButtonElement).value;
  if(valor=="0"){
    corretos++;
    correctSound.play();
    i=i+3;
    srpedro.src = "./resources/images/srpedrofrases.png";
    fase_atual++;
    frases.text = '';
    if(fase_atual >= maximoFases){
      geraPaginaFinal(e);
    }
    else geraPagina();
  }
  else{
    vidas--;
    if(vidas > 0){
      gameoverSound.play();
      defineVidas();
      frases.text = valor;
      srpedro.src = "./resources/images/mulhererrou.png";
    }
    else{
      frases.text = valor;
      gameoverSound.play();
      gameOverPage();
    }

  }
}