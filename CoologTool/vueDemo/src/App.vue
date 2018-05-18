<template>
    <div id="app">
        <button class="normalButton" v-on:click="openLogWebSocket" :disabled="isSocketOn">Start</button>
        <button class="normalButton" v-on:click="closeLogWebSocket" :class="{hidden:!isSocketOn}">Stop</button>
        <div class="listWrap">
            <virtual-list ref="vsl" class="list" :variable="getVariableHeight" 
            :size="78" 
            :remain="7">
              <item
                v-for="(item, index) of items" 
                :key="index"
                :index="index"
                :height="item.height"
                :content="item.content"
                :textStyle="item.textStyle"> 
              </item>
          </virtual-list>
        </div>
    </div>
</template>

<script>
import Vue from 'vue'
import virtualList from 'vue-virtual-scroll-list';
import item from './item.vue';
import VueNativeSock from 'vue-native-websocket'

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
        ws: null,
        totalHeight: 40,
        scrolling: false,
        isSocketOn: false,
    }
  },

  methods: {
    getVariableHeight (index) {
      let target = this.items[index];
      return target.height;
    },

    openLogWebSocket() {
      this.$connect();
      this.$options.sockets.onopen = function() {
        this.isSocketOn = true;
      };
      this.$options.sockets.onclose = function() {
        this.isSocketOn = false;
      };
      this.$options.sockets.onerror = function(event) {
        this.isSocketOn = false;
      };
      this.$options.sockets.onmessage =  function(evt) {
        let rowHeight = 15 * Math.ceil((evt.data.length / 134)+1);
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
          height: rowHeight,
          content: evt.data,
          textStyle: 'color:'+textColor
        };
        this.totalHeight += rowHeight;
        this.items.push(itm);

        if (!this.scrolling) {
          this.scrolling = true;
          setTimeout(() => {
            this.$refs.vsl.setScrollTop(this.totalHeight);
            this.scrolling = false;
          }, 100);
        }
      };
    },

    closeLogWebSocket() {
      this.$disconnect();
    }
  }
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
      padding: 5px 10px 5px 10px;
      font-size: 16pt;
    }

    .hidden {
      display: none;
    }

    .listWrap {
        position: relative;
        margin-top: 10px;
    }

    .list {
        background: #fff;
        border-radius: 3px;
        border: 1px solid #ddd;
        -webkit-overflow-scrolling: touch;
        overflow-scrolling: touch;
    }

</style>