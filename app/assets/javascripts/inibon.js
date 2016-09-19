function toggleInibon(e){
  if($('body').hasClass('inibonning')){
    $('body').removeClass('inibonning');
    $('[data-inibon-key]').off('click.inibon');
  } else {
    $('body').addClass('inibonning');
    $('[data-inibon-key]').on('click.inibon', function(){
      window.open('/inibon/keys/'+$(this).data('inibon-key').replace(/\./g,':').replace(new RegExp('^'+i18n_locale + '\.'),''));
      return false;
    });
  }

  return false;
};

