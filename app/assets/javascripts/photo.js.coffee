$(document).ready ->
  fileCount = 0
  $uploadList = $('#upload .upload-list') 
  # trigger file upload browser on Browse click 
  $('#dropzone .browse').click (e) ->
    $('#fileupload').click()
  $('#fileupload').fileupload({ 
    dataType: 'json', 
    # this element will accept file drag/drop uploading 
    dropZone: $('#dropzone'), 
    add: (e, data) ->
      name = data.files[0].name
      name = name.substring(0, name.lastIndexOf('.'))
      tpl = $('<li class="working list-group-item"><span class="pull-left thumb" id="'+name+'"></span><input type="text" value="0" data-width="48" data-height="48"'+ ' data-fgColor="#0788a5" data-readOnly="1" data-bgColor="#3e4043" /><p></p><span></span></li>') 
      fileCount++
      # Append the file name and file size 
      tpl.find("p").text(data.files[0].name).append "<i>" + formatFileSize(data.files[0].size) + "</i>" 
      # Add the HTML to the UL element 
      data.context = tpl.appendTo($uploadList) 
      # Initialize the knob plugin 
      tpl.find("input").knob() 
      # Listen for clicks on the cancel icon 
      tpl.find("span").click -> 
        jqXHR.abort() if tpl.hasClass("working")
        tpl.fadeOut -> 
          tpl.remove() 
      #Automatically upload the file once it is added to the queue 
      jqXHR = data.submit() 
    progress: (e, data) -> 
      # Calculate the completion percentage of the upload 
      progress = parseInt(data.loaded / data.total * 100, 10) 
      # Update the hidden input field and trigger a change 
      # so that the jQuery knob plugin knows to update the dial 
      data.context.find("input").val(progress).change() 
      data.context.removeClass "working" if progress is 100 
    fail: (e, data) -> 
      data.context.addClass "error"
      addFlash('danger', 'Already loaded a page with the same name!')
      $('li.error').remove()
    done: (e, data) ->
      file = data.result
      name = file.filename
      name = name.substring(0, name.lastIndexOf('.'))
      $('#'+name).prepend(file.thumb)
  }) 

  formatFileSize = (bytes) -> 
    return "" if typeof bytes isnt "number" 
    return (bytes / 1000000000).toFixed(2) + " GB" if bytes >= 1000000000 
    return (bytes / 1000000).toFixed(2) + " MB" if bytes >= 1000000 
    (bytes / 1000).toFixed(2) + " KB" 
    # Prevent the default action when a file is dropped on the window 
  $(document).on "drop dragover", (e) -> 
      e.preventDefault()
