<template>
  <div id="app">
    <button class="normalButton" v-on:click="openLogWebSocket" :disabled="isSocketOn">Start</button>
    <button class="normalButton" v-on:click="closeLogWebSocket" :class="{hidden:!isSocketOn}">Stop</button>
    <input type="text" class="search" v-model="searchText" v-on:keypress="searchInputKeypressed" placeholder="search">
    <span style="color:grey" v-if="this.searchText.length>0" v-bind:style="searchSpanStyle">{{this.searchItems.length + ' logs contains "' + this.searchText + '"'}}</span>
    <div class="listWrap" ref="listWrap">
      <virtual-list ref="vsl" class="list" 
      :start="startIndex" 
      :variable="getVariableHeight" 
      :size="75" 
      :remain="7"
      :bench="40">
        <item
          v-for="(item, index) of filterItems" 
          :key="index"
          :index="index"
          :height="item.height"
          :content="item.content"
          :textStyle="item.textStyle"
          :backgroundColor="item.backgroundColor"> 
        </item>
      </virtual-list>
    </div>
    <input type="text" class="filter" v-model="filterText" placeholder="Filter">
  </div>
</template>

<script>
import Vue from 'vue'
import VueNativeSock from 'vue-native-websocket'
import virtualList from 'vue-virtual-scroll-list';
import item from './Item.vue';

let url = getQueryString("host");
if (url != null) {
  Vue.use(VueNativeSock, getQueryString("host"), { 
          connectManually: true,
          reconnection: true, 
          reconnectionAttempts: 10,
          reconnectionDelay: 5000,
        });
}

export default {
  name: 'app',
  components: { item, 'virtual-list': virtualList },

  data () {
    return {
      items: new Array({height: 40, content: 'Coolog', textStyle:'color:#1E90FF;font-size:26px'}),
      searchItems: new Array(),

      scrolling: false,
      isSocketOn: false,
      isSocketConnecting: false,
      startIndex: 0,
      currentSearchItemIndex: -1,
      currentSearchItem: null,

      filterText: '',
      searchText: '',

      searchSpanStyle: {
        visibility: 'hidden',
      }
    }
  },

  watch: {
    searchText: function (newVal, oldVal) {
      if (newVal != oldVal) {
        this.resetSearch();
      }
    },
    filterText: function (newVal, oldVal) {
      if (newVal != oldVal) {
        this.resetSearch();
      }
    },
  },

  computed: {
    filterItems: function () {
      var filterItems = this.items;
      filterItems = filterItems.filter(this.itemFilter);
      return filterItems;
    },
  },

  methods: {
    getVariableHeight (index) {
      let target = this.items[index];
      return target.height;
    },

    openLogWebSocket () {
      if (this.isSocketConnecting) {
        return;
      }
      this.isSocketConnecting = true;
      this.$connect();
      this.$options.sockets.onopen = function () {
        this.isSocketOn = true;
      };
      this.$options.sockets.onclose = function () {
        this.isSocketOn = false;
        this.isSocketConnecting = false;
        this.closeLogWebSocket();
        this.removeWebSocketListener();
      };
      this.$options.sockets.onerror = function (event) {
        this.isSocketOn = false;
        this.isSocketConnecting = false;
        this.closeLogWebSocket();
        this.removeWebSocketListener();
      };
      this.$options.sockets.onmessage =  function (evt) {
        let rowHeight = 15 * Math.ceil((getStringLength(evt.data) / 219)+1);
        let type = evt.data.match(/\[##TYPE:(\S*)##\]/)[1];
        var textColor = '#000000';
        if (type === 'Debug') {
          textColor = '#696969';
        } else if (type === 'Info') {
          textColor = '#006400';
        } else if (type === 'Warning') {
          textColor = '#FF7F50';
        } else if (type === 'Error') {
          textColor = '#FF0000';
        }
        let itm = {
          index: this.items.length,
          height: rowHeight,
          content: evt.data,
          textStyle: 'color:'+textColor,
          backgroundColor: 'white',
        };
        this.items.push(itm);
        this.startIndex = this.items.length;
      };
    },

    closeLogWebSocket () {
      this.$disconnect();
    },

    removeWebSocketListener () {
      delete this.$options.sockets.onopen;
      delete this.$options.sockets.onclose;
      delete this.$options.sockets.onerror;
      delete this.$options.sockets.onmessage;
    },

    searchInputKeypressed (event) {
      if (event.keyCode != 13) {
        return;
      }
      this.searchSpanStyle.visibility = 'visible';
      this.searchItems = this.getSearchItems();

      if (this.currentSearchItem != null) {
        this.currentSearchItem.backgroundColor = 'white';
        this.currentSearchItem = null;
      }

      if (this.searchItems.length > 0) {
        if (this.currentSearchItemIndex >= 0) {
          this.currentSearchItemIndex += 1;
        } else {
          this.currentSearchItemIndex = 0;
        }
        if (this.currentSearchItemIndex>=this.searchItems.length) {
            this.currentSearchItemIndex = 0;
        }
        this.searchItems[this.currentSearchItemIndex].backgroundColor = '#FFFFE0';
        let offset = this.$refs.vsl.getVarOffset(this.searchItems[this.currentSearchItemIndex].index, true);
        // alert('index:'+this.searchItems[this.currentSearchItemIndex].index+', offset:'+offset);
        this.$refs.vsl.setScrollTop(offset);
        this.currentSearchItem = this.searchItems[this.currentSearchItemIndex];
      }
    },

    getSearchItems () {
      if (this.searchText == null || this.searchText.length === 0) {
        return new Array();
      }
      
      this.filterItems = new Array();
      var searchItems = this.filterItems;
      if (this.items.length !==  searchItems.length) {
        for (var i=0, len=searchItems.length;i<len;i++) {
          searchItems[i].index = i;
        }
      }
      searchItems = searchItems.filter(this.itemSearcher);
      return searchItems;
    },

    itemFilter (item) {
      return (item.content.indexOf(this.filterText) != -1);
    },

    itemSearcher (item) {
      return (item.content.indexOf(this.searchText) != -1);
    },

    resetSearch () {
      this.searchSpanStyle.visibility = 'hidden';
      this.searchItems = new Array();
      this.currentSearchItemIndex = -1;
    }
  }
}

function getStringLength(str) {
  var realLength = 0, len = str.length, charCode = -1;
  for (var i = 0; i < len; i++) {
    charCode = str.charCodeAt(i);
    if (charCode >= 0 && charCode <= 128) 
       realLength += 1;
    else
       realLength += 2;
  }
  return realLength;
}

function getQueryString(name) {  
  var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");  
  var r = window.location.search.substr(1).match(reg);  
  if (r != null) return unescape(r[2]); return null;  
}
</script>

<style>
    .normalButton {
      position: relative;
      font-family: Helvetica;
      margin: 5px 0px 5px 0px;
      font-size: 16pt;
    }

    .hidden {
      display: none;
    }

    .listWrap {
      position: relative;
      height: 560px;
    }

    .list {
      background-color: #fff;
      border-radius: 3px;
      border: 1px solid #ddd;
      -webkit-overflow-scrolling: touch;
      overflow-scrolling: touch;
    }

    .filter {
      position: relative;
      width: 150px;
      font-size: 16pt;
    }

    .search {
      position: relative;
      width: 250px;
      font-size: 14pt;
    }

</style>