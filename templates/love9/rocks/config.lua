rocks_trees = { "rocks" }
rocks_provided = {
<% for name, version in pairs(versions) do -%>
	<%- name %> = <%- string.format("%q", version) %>,
<% end -%>
}
loverocks = {
	version = <%- string.format("%q", loverocks_version) %>
}
