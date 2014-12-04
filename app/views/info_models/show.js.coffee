children = "<%= escape_javascript(render(:partial => 'children')) %>"
$('#<%= @parent.id %>.child').html(children)