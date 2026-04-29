// ドキュメント全体でマウスオーバーを監視
document.addEventListener('mouseover', (event) => {

    // ホバーされた要素が <a> タグ（リンク）かどうかをチェック
    const link = event.target.closest('a');

    if (link) {
        // リンクの href 属性を取得してコンソールに出力
        console.log(link.href);
    }
});
