// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery.knob
//= require photo
//= require bootstrap-slider
//= require jquery-fileupload/basic
//= require social-share-button




$(window).load(function(){
  dropFlash();
  if($('.first-time').length > 0){
      $('.welcome').modal('show');
  }
});
$(document).ready( function(){

  $('.login-butt').click(function(){
    $('.signin').modal('show');
  });



  $('.slider').slider().on('slideStop', function(){
    speed = $('input.slider').val();

    $.post( "/users/set_speed", {data: speed}, function( data ) {
    });
  });


  $('.instructions').click(function(){
    $('.welcome').modal('show');
  });


  $('.fb-feed').click(function(){
    FB.ui({
    method: 'feed',
    link: 'http://146.185.151.250:1111/',
    caption: $('.gameinfo .myscore').html() +
    $('.gameinfo .score').html() + $('.gameinfo .in').html() + $('.gameinfo .time').html() +
    $('.gameinfo .seconds').html() + $('.gameinfo .caption').html()
    ,
    description: $('.gameinfo .description').html(),
    picture: 'http://146.185.151.250:1111/assets/logo-inv-42ce47f6741cfbf8d1969c3fe90ea582.png'
  }, function(response){});
  });
  counter = -1;
  words = [];

  $('#click-upload').click(function(e){
    e.preventDefault();
    $('#file-upload').click();
  });

  $('input[id=file-upload]').change(function() {
    var path = $(this).val();
    path = path.substring(path.lastIndexOf('\\')+1)
    $('span.filename').html(path);
    });

  $('.start').on('click', function(e){
    e.preventDefault();

    $(this).fadeOut(200, function(){
      $('.restart').removeClass('hide');
    });

    $(".one").animate({opacity: 1.0, left: +100}, 600).animate({opacity: 0.0, left: +100}, 400).queue(function(){
      $(".two").animate({opacity: 1.0, left: -100}, 600).animate({opacity: 0.0, left: -100}, 400).queue(function(){
        $(".three").animate({opacity: 1.0, left: +100}, 600).animate({opacity: 0.0, left: +100}, 400).queue(function(){
          $(".go").animate({opacity: 1.0, zoom: 2}, 400).animate({opacity: 0.0, zoom: 4}, 400).queue(function(){
            $('#input').focus();
            start();
          });
        });
      });
    });
  });

  $( "#input" ).keypress(function( event ) {
    if ( event.which == 13 ) {
       event.preventDefault();
       clearAndMove();
    }
  });
  //$('.upper-box').append($('.image-holder img'));
});


function start(){
  startTime = new Date().getTime() / 1000;
  speed = $('.speed').html();
  y = 0;
  gameOver = false;
  max = $('.image-holder').children().length;
  moveNewWord();
}

function moveWord(){
  if(y + 200 > $('.upper-box').height()){
    $('#input').addClass('shadow');
  }
  if(y + 30 > $('.upper-box').height()){
    //catchWord();
    clearAndMove();
  }
  y = y + ((8 - currentFactor)* speed/5);
  currentWord.css('top',y+'px');
}

function catchWord(){
  var wrd = $('#input').val();
  words = words.concat(wrd);
  console.log(wrd)
  console.log(words)
}

function clearAndMove(){
  if(gameOver)
    return false;
  catchWord();
  $('#input').val('');
  $('#input').removeClass('shadow');
  if(currentWord.length){
    cw = currentWord.remove();
    $('.image-holder').append(cw);
  }
  clearTimeout(animation);
  moveNewWord();
}
function sendData(arr, time){
  var gameID = $('.gameinfo .game-id').attr('id');
  $.post( "/submit_score", {data: arr, time: time, game: gameID }, function( data ) {
    $( ".endGame .modal-body p" ).html( data.total );
    $('.gameinfo .score').html(data.score);
    $('.gameinfo .time').html(data.time);
  });
}
function endGame(){
  gameOver = true;
  endTime = new Date().getTime() / 1000;
  time = endTime - startTime
  $('#input').removeClass('shadow');
  $('.endGame').modal('show');

  fin = [];
  for(var i=0; i < max; i++){
    wt = $('img#'+i);
    wr = {};
    wr.id = $(wt).attr('name');
    wr.guess = words[i];
    fin = fin.concat(wr);
  }
  console.log(fin);
  sendData(fin, time);
}
function animateBar(){
  var prog = (counter / max) * 100;
  var diff = 100 - prog;
  $('.progress').animate({bottom: -diff+'%', height: prog+'%'}, 'fast');
}
function moveNewWord(){
  y = 0;
  counter = counter + 1;

  //animate progress bar
  animateBar();
  if(counter == max){
    endGame();
    return false;
  }

  currentWord = $('.image-holder img#'+counter).remove();
  currentFactor = currentWord.width() * 0.3;
  $('.upper-box').append(currentWord);
  x = Math.random() * 500;
  currentWord.css('left', x+'px');
  currentWord.css('top','-20px');
  animation = setInterval(function(){moveWord()}, 100);
}

  function addFlash(cls, msg){
    var flash = '<div class="alert fade in alert-'+cls+'"><button class="close" data-dismiss="alert">×</button>'+msg+'</div>'
    $('#main-container').prepend(flash);
    dropFlash();
  }
  function dropFlash(){
    $('.alert').animate({top: 40}, 800);
  }