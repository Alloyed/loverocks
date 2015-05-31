rocks_provided = {
	<% for name, version in pairs(versions) do %>
	<%- name %> = <%- string.format("%q", version) %>,
	<% end %>
}
