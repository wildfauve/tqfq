systems = "<%= escape_javascript(render(:partial => 'systems')) %>"
$('#<%= @child.id %>.systems').html(systems)