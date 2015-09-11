<div class="body-content">
	<div class="chat-top">{include file='chat/chat-breadcrumb.tpl'}</div>
	<!--[if lt IE 7]>
            <p class="chromeframe">You are using an outdated browser. <a href="http://browsehappy.com/">Upgrade your browser today</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to better experience this site.</p>
        <![endif]-->

	<div class="chat-wrapper">
		<div class="chat-content">
			<div class="chat-panel chat-panel-left" id="panel-chats">
				<div>
					<div class="chat-header">
						<h3>Chat List</h3>
						<!-- <span class="chat-search tooltip" title="Search a chat room"></span> -->
						<span class="chat-add tooltip" id="chat-add" title="Add a new chat room"></span>
					</div>
					<div class="chats-frame">
						<ul class="chats-list" id="rooms_tabs">
							{section name=chats loop=0}
							<li data-id="88" class="active">
	<span class="chat-photo">
		<img src="../img/no_photo_user_ico_male.png" alt="Prueba Prueba Prueba">
		<div class="user-photo-ribbon user-photo-ribbon-2"></div>
	</span>
	<span class="chat-news" style="visibility: hidden;">0</span>
	<span class="chat-name">Prueba Prueba Prueba</span>
	<span class="chat-abroad">ABR - Spain - Sevilla</span>
	<span class="chat-last-hour"></span>
</li>
							{/section}
						</ul>
					</div>
					<div class="chat-footer">
						<!--
						<span class="lock-icon open tooltip" title="Block user"></span>
						<span class="delete-icon tooltip" title="Delete chat room"></span>
						-->
					</div>
				</div>
			</div>
			<div class="chat-panel chat-panel-right" id="panel-rooms">
				<div>
					<div id="rooms">
						<div class="chat-room active">
							<div class="chat-header">
								<h3>Select an user to chat</h3>
							</div>
							<div class="messages-frame"></div>
						</div>
					</div>
					<div class="message-new">
						<form class="message-form" id="message-form">
							<input type="button" class="message-attach tooltip" id="message-attach" title="Send image. Max filesize {ini_get('upload_max_filesize')}" />
							<div class="center-input">
								<input type="text" class="message-input" id="message-text" placeholder="Type your message here" />
							</div>
							<input type="file" class="message-input-hidden" id="message-image" accept="image/*" />
							<input type="submit" class="message-send tooltip" value="Send" title="Send your message"/>
						</form>
					</div>
				</div>
			</div>
			<div class="chat-panel chat-panel-right chat-panel-shadow inactive" id="panel-search">
				<div>
					<div>
						<h3>
							Select an user to add chat <span class="search-close tooltip" id="search-close" title="Close"></span>
						</h3>
						<div class="search-frame">
							<ul class="search-list" id="search-list">
								{section name=search loop=0}
								<li>
									<span class="search-photo"><img src="../img/users/1935_Carlos.png" alt="Carlos  Fernández Durán"> </span> <span class="search-name">Carlos Fernández Durán</span> <span class="search-abroad">Abroadster - USA - St. Louis</span>
								</li>
								{/section}
							</ul>
						</div>
					</div>
					<div class="search-filters">
						<div class="center-input">
							<input type="text" class="search-filter-input" id="search-filter-text" placeholder="search..." />
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
