> El fuente de URLHunter está en la rama GitHub, la rama Master está vacia

# Creando URLHunter.

Vamos a demostrar que no hace falta ser un figura para hacer algo muy util y aparente. Vaya por delante que, si somos capaces de hacer esto es porque existen páginas como las de [Railscasts][1].
Lo primero que hacemos después de crear nuestro nuevo proyecto Rails es instalar las gemas necesarias para trabajar con Twitter Bootstrap, del que somos fans.

    gem 'therubyracer'
    gem 'less-rails'
    gem 'twitter-bootstrap-rails'
        
Después de cargar las gemas en nuestro proyecto con Bundle Install, terminamos de instalar Bootstrap en nuestro proyecto con la siguiente instrucción:

	rake g bootstrap:install

El propósito de nuestra aplicación es mostrar un listado de los tweets de [@objectivec_es][2] que contienen una url. De esta forma tendremos agrupados en una web toda esa información tan interesante que van soltando a nuestro timeline y que muchas veces perdemos por no hacer un favorito a tiempo. Dicho esto, de primeras lo que vamos a necesitar es una página en la que mostraremos información procedente del API de Twitter.

Creamos un controlador para las páginas de contenido estático:

	rake g controller StaticPages home help

Y hacemos algunos ajuste en el _layout_ general para empezar a beneficiarnos de Twitter Bootstrap

	<!DOCTYPE html>
	<html>
	<head>
	  <title>URLHunter</title>
	  <!--[if lt IE 9]>
	  <script src="http://html5shim.googlecode.com/svn/trunk/html5.js" type="text/javascript"></script>
	  <![endif]-->
	  <%= stylesheet_link_tag    "application", :media => "all" %>
	  <%= javascript_include_tag "application" %>
	  <%= csrf_meta_tags %>
	  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	</head>
	<body>
	<div class="container">
	  <div class="row">
	    <div class="span9"><%= yield %></div>
	    <div class="span3">
	      <h2>¿Por qué?</h2>
	      <p>Porque alguien tenía que hacerlo. Si no, Twitter volvería a cambiar su API para eliminar la funcionalidad de favoritos.</p>
	    </div>
	  </div></div>
	</body>
	</html>

## Accediendo al API de Twitter

Para recuperar el timelime de nuestra "presa" podemos desarrollar las llamadas que necesitemos o utilizar la gema "Twitter". Siguiendo la filosfía DRY y como hay otras cosas mucho mejores que hacer, nosotros nos decantamos por la gema.

	gem 'twitter'

Antiguamente ya podríamos hacer algunas pruebas con la consola pero en los tiempos que corren hay que autenticarse. Para ello, siguiendo la documentación de la gema, hay que crear un fichero de inicialización en /config/initializers llamado twitter.rb:

	Twitter.configure do |config|
	  config.consumer_key = YOUR_CONSUMER_KEY
	  config.consumer_secret = YOUR_CONSUMER_SECRET
	  config.oauth_token = YOUR_OAUTH_TOKEN
	  config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
	end

Una vez hayamos reemplazado los valores aplantillados con los que podemos encontrar en la sección de "Mis applicaciones" de la web de desarrolladores de Twitter ya estaremos en condiciones de empezar a consumir datos de Twitter.

Inicialmente, vamos a probar que tal funciona todo incluyendo lo siguiente en el home.html.erb:

	<h1>Todos los links de @objectivec_es</h1>
	<div id="tweets-with-links">
	  <% Twitter.user_timeline("objectivec_es", :count => 10, :exclude_replies => true).each do |tweet| %>
	    <blockquote> <%= tweet.text %> </blockquote>
	  <% end %>
	</div>

¿Igualito que en iOS, eh? Bueno, cada uno tiene sus virtudes. En cualquier caso, aunque hemos obtenido rapidos resultados no podemos decir que sean _bonitos_. Lo suyo sería que los hashtags, las menciones y los links tuvieran los vinculos correspondientes. Para eso vamos a utilizar otra gema.

	gem 'twitter-text'

Según la documentación de la gema, para _autolinkar_ las entidades lo único que tenemos que hacer es lo siguiente:

A *app/helpers/application_helper.rb* lo dejaremos de esta forma

	module ApplicationHelper
	  include Twitter::Autolink
	end

Y en *home.html.erb* cambiaremos el contenido de la cita por lo siguiente:

	<blockquote> <p><%= auto_link(tweetlink.content).html_safe %></p> </blockquote>

>Es necesario poner html_safe al final para que Rails interprete que le estamos pasando un texto que contiene etiquetas HTML, si no lo hicieramos las etiquetas se pintarían como si fuera texto plano.

Si recargamos ahora la página veremos todos los tweets con enlaces a los usuarios mencionados, a los hasgtags... Como diría Duke Nukem: "Ah!, much better!!!"


Lo siguiente que vamos a hacer es almacenar los tweets en base de datos. ¿Por qué?, pues por varios motivos:

- No queremos perder ni una sola de estas píldoras de información
- Ahora no son muchos pero cuando los chicos de [@ObjectiveC_es][2] vayan por los 3000 tweets esta web tardará bastante más en cargar
- En esta vida, no eres nadie si no haces un poco de persistencia.

Así que crearemos un modelo para almacenar algunos datos. Inicialmente será muy sencillo, ya lo complicaremos más adelante:

	rails g model tweetlink tweet_id screen_name content:text profile_image tweet_created_at

e incluiremos algunos métodos de conveniencia en la nueva clase:

	class Tweetlink < ActiveRecord::Base
	  attr_accessible :content, :screen_name, :tweet_id, :profile_image, :tweet_created_at

	  def self.first_time
	    Twitter.user_timeline("objectivec_es", :count => 3200, :exclude_replies => true).each do |tweet|
	      insert_tweet(tweet)
	    end
	  end

	  def self.pull_tweets
	    Twitter.user_timeline("objectivec_es", :count => 200, :exclude_replies => true, :since_id => maximum(:tweet_id)).each do |tweet|
	      insert_tweet(tweet)
	    end
	  end

	  def self.insert_tweet(tweet)
	   unless exists?(tweet_id: tweet.id)
	     if tweet.retweet?
	       tweet = tweet.retweeted_status
	     end
	     if tweet.urls.any?
	       create!(
	           tweet_id: tweet.id,
	           content: tweet.text,
	           screen_name: tweet.user.screen_name,
	           profile_image: tweet.user.profile_image_url,
	           tweet_created_at: tweet.created_at,
	       )
	     end
	   end
	  end
	end

A continuación, tendremos que cambiar el controlador y la vista ya que ahora mismo todavía están recuperando la información directamente desde el API.

El metodo _home_ quedará de la siguiente manera:

	def home

	  @tweetlinks = Tweetlink.all

	  @tweetlinks.empty? ? Tweetlink.first_time : Tweetlink.pull_tweets

	  respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @tweetlinks }
	  end

	end

Y la vista de esta otra forma:

	<h1>Todos los links de @objectivec_es</h1>
	<div id="tweets-with-links">
	  <% @tweetlinks.each do |tweetlink| %>
	    <blockquote>
	      <%= image_tag tweetlink.profile_image %>
	      <%= tweetlink.screen_name %> wrote at
	      <%= l DateTime.parse(tweetlink.tweet_created_at), :format => :long %>
	      <p><%= auto_link(tweetlink.content).html_safe %></p>
	    </blockquote>
	  <% end %>
	</div>

Para terminar vamos a incluir paginación, esto reducirá el tiempo de carga de la página y mejorará la usabilidad. Otra vez más, podriamos escribir todo el código necesario para montar una paginación pero con un par de gemas lo podemos dejar solucionado:

	gem 'will_paginate'
	gem 'bootstrap-will_paginate'

La gema *will_paginate* es la que se encarga de la gestión de la paginación. Lo único que tendremos que hacer es cambiar el número de registros que recuperamos de la clase Tweetlink en el controlador. En lugar de _all_ usaremos _paginate_:

  def home

    @tweetlinks = Tweetlink.paginate(page: params[:page])

    @tweetlinks.empty? ? Tweetlink.first_time : Tweetlink.pull_tweets

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweetlinks }
    end

  end

En el layout, indicaremos donde queremos que aparezca el componente de paginación. La gema *bootstrap-will_paginate* aplica los estilos de Twitter Bootstrap a paginación.

	<h1>Todos los links de @objectivec_es</h1>
	<%= will_paginate @tweetlinks %>
	<div id="container">
	  <% @tweetlinks.each do |tweetlink| %>
	    <blockquote>
	      <%= image_tag tweetlink.profile_image %>
	      <%= tweetlink.screen_name %> wrote at
	      <%= l DateTime.parse(tweetlink.tweet_created_at), :format => :long %>
	      <p><%= auto_link(tweetlink.content).html_safe %></p>
	    </blockquote>
	  <% end %>
	</div>
	<%= will_paginate @tweetlinks %>

Y listo, podríamos seguir incluyendo muchas mejoras y posiblemente es lo que hagamos en los próximos días pero por el momento... esto es todo.


[1]: http://railscasts.com "Railscasts"
[2]: http://twitter.com/objectivec_es "@ObjectiveC_es"
