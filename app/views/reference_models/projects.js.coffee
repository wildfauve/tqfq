systems = "<%= escape_javascript(render(:partial => 'projects')) %>"
$('#<%= @child.id %>.projects').html(systems)