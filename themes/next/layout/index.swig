{% extends '_layout.swig' %}
{% import '_macro/post.swig' as post_template %}
{% import '_macro/sidebar.swig' as sidebar_template %}

{% block title %} {{ config.title }} {% endblock %}

{% block page_class %}
  {% if is_home() %} page-home {% endif %}
{% endblock %}

{% block content %}
  <div id="posts" class="posts-expand">
    {% for post in page.posts %}
      {% if loop.index <= config.per_page %}
        {{ post_template.render(post, true) }}
      {% endif %}
    {% endfor %}
  </div>

  {% include '_partials/pagination.swig' %}
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}

{% block comment_system %}
  {% include '_scripts/comments/duoshuo.swig' %}
  {% include '_scripts/comments/disqus.swig' %}
{% endblock %}