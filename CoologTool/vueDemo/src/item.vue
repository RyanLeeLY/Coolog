<template>
    <div class="item" :style="style">
        <span class="content" :style="textStyle">{{ content }}</span>
    </div>
</template>

<script>
    export default {
        props: {
            index: Number,
            height: Number,
            content: String,
            textStyle: String,
            backgroundColor: String,
        },

        computed: {
            style () {
                return {
                    'height': this.height + 'px',
                    'background-color': this.backgroundColor
                };
            },
        }
    }
</script>

<style>
    .item {
        position: relative;
        box-sizing: border-box;
        padding-top: 2px;
        padding-left: 8px;
        padding-right: 8px;
        border-bottom: 1px solid #eee;
    }
    .content {
        /* position: absolute; */
        width: 96%;
        height: 100%;
        word-break:break-all;
        font-size: 12pt;
    }
</style>
