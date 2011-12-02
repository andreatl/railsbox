$(document).ready(function() {
  
  function getSelected(single, type) {
    if(type === undefined) {
      var value = $('#file-container > .row-container > .mark-it > .tick:checked');
      //Nothing is selected
      if(value.size() < 1) {
        alert('Please select an item');
        return false;
      }
    } else {
      var value = $('#file-container > .row-container > .mark-it > .' + type + 'Tick:checked');
      //Nothing is selected of the specified type
      if(value.size() < 1) {
        alert('Please select a ' + type);
        return false;
      }
    }

    if(single && value.size() > 1) {
      //More than 1 item selected if single is true
      alert('Please select only 1 item');
      return false;
    } else {
      var result = new Object();

      //Get Folders
      if(type === undefined || type == "folder") {
        var folders = [];
        value.filter("[id^='directory_']").each(function(index, element) {
          folders.push(element.id.split('_').pop());
        });
        result.folders = folders;
      }

      //Get Files
      if(type === undefined || type == "file") {
        var files = [];
        value.filter("[id^='file_']").each(function(index, element) {
          files.push(element.id.split('_').pop());
        });
        result.files = files;
      }
      return result;
    }
  }


  $('#mark_it').click(function() {
    //select all box..
    var checked = this.checked;
    $('#file-container input:checkbox').each(function() {
      if(!this.disabled) {
        this.checked = checked;
      }
    });
  });
  /******************** MOVE ****************/

  $('#move-link').click(function(e) {
    e.preventDefault();

    var selected = getSelected(false);
    if(selected) {
      if(selected.folders.length > 0 && selected.files.length > 0) {
        alert('Please select either folders or files');
        return false;
      } else if(selected.folders.length > 0) {
        $.colorbox({
          href : '/folders/move/' + selected.folders.join(','),
          onComplete : function() {
            makeFolderStructure('#folderMove', '#allFolders_' + selected.folders.join(',#allFolders_'));
            $('#move', '#cboxLoadedContent').click(function() {
              moveItems();
            });
          }
        });
      } else if(selected.files.length > 0) {
        $.colorbox({
          href : '/assets/move/' + selected.files.join(','),
          onComplete : function() {
            makeFolderStructure('#folderMove', false);
            $('#move', '#cboxLoadedContent').click(function() {
              moveItems();
            });
          }
        });
      }
    }
  });
  //Get child elements of a folder
  function makeFolderStructure(parent, exclude) {
    if(exclude == false) {
      var children = $('li a', parent);
    } else {
      //If moving a folder exclude the current folder(s) from being selected
      var children = $('li:not("' + exclude + '") a', parent);
      $(exclude).addClass('disabled').click(function() {
        return false;
      });
    }
    $(children).toggle(
    //Open
    function() {
      if($(this).parent().find('ul:first').length > 0) {
        //already got folders
        $(this).parent().find('ul:first').show();
      } else {
        //Get folders
        $('#moveDialogLoading').show();
        var x = this;
        $.get($(x).attr('href'), function(data) {
          $(x).parent().append(data);
          makeFolderStructure($(x).parent().find('ul:first'), exclude);
          $('#moveDialogLoading').hide();
        });
      }
      if (!($(this).parent().attr('id') == "allFolders_" && canHome == false)){
        moveFolderSelect(this);
      }
      
      $(this).addClass('opened');
      return false;
    },
    //Hide
    function() {
      $(this).removeClass('opened').parent().find('ul:first').hide();
      if (!($(this).parent().attr('id') == "allFolders_" && canHome == false)){
        moveFolderSelect(this);
      }
      return false;
    });
  }

  //When a destination folder is selected
  function moveFolderSelect(element) {
    var path = "";
    var x = $(element);
    do {
      if(path != "") {
        path = x.html() + "/" + path;
      } else {
        path = x.html();
      }
      x = x.closest('ul').prev('a')
    } while(x.length > 0);
    $('#selectedFolder').html(path);
    $('.moveTarget', '#moveForms').val($(element).parent().attr('id').split('_').pop());
    //add folder id to each of the input boxes
    $('li a.selected', '#folderMove').removeClass('selected');
    $(element).addClass('selected');
    $.colorbox.resize();
  }

  //Execute move
  function moveItems() {
    var forms = $('form', '#moveForms');
    var completed = 0;
    
    if (canHome == false && $('.moveTarget:first', '#moveForms').val() == ""){
      alert('Insufficient Permissions');
    }else{
      $(forms).each(function(index, element) {
        $(element).ajaxSubmit({success: function(responseText, statusText){
          completed++;
          var x = $('#errorExplanation li',responseText);
          if (x.count>0){
            alert(x.html());
          }
          else if (forms.length == completed){
            window.location.reload();
          }
          
        }});
      });
    }
  }

  /**************END OF MOVE*****************/

  /**************Details*****************/

  function getDetails(isFolder, href) {
    $.colorbox({
      href : href,
      onComplete : function() {
        //Rename
        $('a.edit:first', '#cboxLoadedContent').click(function(e) {
          e.preventDefault();
          $('#rename-link').trigger('click');
        });
        //Edit permissions
        $('li .permName a', '#permissions').colorbox({
          onComplete : function() {
            $('a.back:first', '#cboxLoadedContent').click(function(e) {
              e.preventDefault();
              getDetails(isFolder, href);
            });
            $('form.button_to:first', '#cboxLoadedContent').submit(function(e) {
              e.preventDefault(true);
              if(confirm('Are you sure you want to delete this permission?')) {
                $.ajax({
                  type : 'DELETE',
                  url : $(this).attr('action'),
                  data : $(this).serialize(),
                  success : function(data, textStatus, jqXHR) {
                    if(textStatus == "success") {
                      getDetails(isFolder, href);
                    }
                  }
                });
              }
            });
            $('.edit_permission:first', '#cboxLoadedContent').submit(function() {
              $.ajax({
                type : 'POST',
                url : $(this).attr('action'),
                data : $(this).serialize(),
                success : function(data, textStatus, jqXHR) {
                  if(textStatus == "success") {
                    getDetails(isFolder, href);
                  }
                }
              });
              return false;
            });
          }//End permission list colorbox complete
        });
        //Add permission
        $('a.addPermission:first', '#cboxLoadedContent').colorbox({
          onComplete : function() {
            colorboxSearchComplete();
            $('a.back:first', '#cboxLoadedContent').click(function(e) {
              e.preventDefault();
              getDetails(isFolder, href);
            });
            $('#new_permission').submit(function() {
              $.ajax({
                type : 'POST',
                url : $('#new_permission').attr('action'),
                data : $('#new_permission').serialize(),
                success : function(data, textStatus, jqXHR) {
                  if(textStatus == "success") {
                    getDetails(isFolder, href);
                  }
                }
              });
              return false;
            });
          }
        });
        if(isFolder == false) {
          //is a file
          $('a.createLink:first', '#cboxLoadedContent').colorbox({
            onComplete : function() {
              hotlinkMakeForm();
            }
          });
        }
      }//End details colorbox complete
    });
  }

  //Individual details button
  $('.row-container', '#file-container').each(function(index, element) {
    $('div.name:first a.details:first', element).click(function(e) {
      e.preventDefault();
      getDetails($(this).closest('.row-container').hasClass('folder'), $(this).attr('href'));
    });
  });
  //Details bottom bar button
  $('#details-link').click(function(e) {
    e.preventDefault();
    var selected = getSelected(true);
    if(selected.folders > 0) {
      getDetails(true, '/folders/details/' + selected.folders[0]);
    } else if(selected.files > 0) {
      getDetails(false, '/assets/details/' + selected.files[0]);
    }
  });
  /**************End of Details*****************/

  $('#new-folder-link').colorbox();

  $('#upload-link').colorbox({
    onComplete : function() {
      $('form:first', '#cboxLoadedContent').submit(function() {
        $(this).parent().addClass('loading');
      });
    }
  });

  //download
  $('#download-link').click(function(e) {
    e.preventDefault();
    var selected = getSelected(false);
    
    if(selected.folders.length == 0 && selected.files.length == 1){
      document.location = '/assets/get/' + selected.files[0];
    }
    else if(selected.folders.length > 0 || selected.files.length > 1){
      $('#download_folders').val(selected.folders.toString());
      $('#download_assets').val(selected.files.toString());
      $('#download_form').submit();
    }
  });
  //rename
  $('#rename-link').click(function(e) {
    e.preventDefault();
    var selected = getSelected(true);
    if(selected.folders > 0) {
      $.colorbox({
        href : '/folders/' + selected.folders[0] + '/rename'
      });
    } else if(selected.files > 0) {
      $.colorbox({
        href : '/assets/' + selected.files[0] + '/rename'
      });
    }
  });
  //hotlink
  $('#hotlink-link').click(function(e) {
    e.preventDefault(true);
    var selected = getSelected(true, 'file');
    if(selected) {
      $.colorbox({
        href : '/hotlink/new/' + selected.files[0],
        onComplete : function() {
          hotlinkMakeForm();
        }
      });
    }
  });
  function hotlinkMakeForm() {
    $('#new_hotlink').submit(function(e) {
      e.preventDefault();
      var valid = true;
      if("!/^\d{0,}$/".match($('#hotlink_days').val().trim())) {
        valid = false;
        $('#hotlink_days').addClass('error');
      } else {
        $('#hotlink_days').removeClass('error');
      }
      if($('#hotlink_link').val().trim() == "") {
        valid = false;
        $('#hotlink_link').addClass('error');
      } else {
        $('#hotlink_link').removeClass('error');
      }
      if($('#hotlink_password').val().trim() == "") {
        valid = false;
        $('#hotlink_password').addClass('error');
      } else {
        $('#hotlink_password').removeClass('error');
      }
      if(valid == true) {
        $('#new_hotlink').ajaxSubmit({success: function(responseText){
          $.colorbox({
              html : responseText,
              onComplete : function() {
                $.colorbox.resize();
                $('#link').click(function() {
                  $(this).select();
                });
              }
            });
        }});
      } else {
        $('#hotlinkError').show();
        $.colorbox.resize();
      }
    });
  }


  $('#delete-link').click(function(e) {
    e.preventDefault();
    var toDelete = $('#file-container > .row-container > .mark-it > .tick:checked');
    if (toDelete.length < 1){
    	alert('Please select an item');
    	return false;
    }
    if(confirm('Are you sure you want to delete ' + toDelete.length + ' items?')) {
      $(toDelete).next('form').each(function(index, element) {
        $(element).ajaxSubmit({
          success : function() {
            $(element).prev('input:checkbox').attr('checked', false);
            $(element).closest('.row-container').slideUp();
          }
        });
      });
      
      $.get('/disk_space #content', function(data){
        var x = data.split(',');
        $('#used-space').animate({width: parseInt(x[0])+"%"});
        $('#remaining').html(x[1]);
      });      
    }
  });
  
});
