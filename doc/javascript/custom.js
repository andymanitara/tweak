;
$( document ).ready(function(){
  $('#content.list.tree > ul > li').click(function(){
    window.top.location.reload();
  });
});