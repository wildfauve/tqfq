summary = "<%= escape_javascript(render(:partial => 'summary')) %>"
$('#<%= @system.id %>').html(summary)