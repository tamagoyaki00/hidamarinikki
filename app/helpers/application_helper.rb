module ApplicationHelper
  def default_meta_tags
    {
      site: 'ひだまり日記',
      title: '',
      reverse: true,
      charset: 'utf-8',
      description: 'ひだまり日記は、日常の小さな幸せや頑張りを気軽に記録できるアプリです。続けるうちに日々の感謝や幸せに気づき、心が前向きになります。',
      keywords: ['感謝日記', 'ポジティブ', '自己肯定感向上', '幸せ日記', '日記'],
      canonical: 'https://hidamarinikki.jp',
      separator: '|',
      icon: [
        { href: image_url('favicon.ico') },
        { href: image_url('himawari180.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png' },
      ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: 'https://hidamarinikki.jp',
        image: image_url('hidamarinikki-ogp.png'),
        locale: 'ja-JP',
      },
      twitter: {
        card: 'summary_large_image',
        image: image_url('hidamarinikki-ogp.png'),
      }
    }
  end
end
