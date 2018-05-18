<template>
    <div class="item" :style="style">
        <p class="content" :style="textStyle">{{ content }}</p>
    </div>
</template>

<script>
    export default {
        props: {
            index: Number,
            height: Number,
            content: String,
            textStyle: String
        },

        computed: {
            style () {
                return {
                    'height': this.height + 'px',
                    'line-height': this.height + 'px'

                }
            },
        }
    }
</script>

<style>
    .item {
        position: relative;
        padding-left: 20px;
        box-sizing: border-box;
        border-bottom: 1px solid #eee;
    }
    .content {
        width: 100%;
        height: 100%;
        word-break:break-all;
        line-height:120%;
    }
</style>
