import '../models/outlet_model.dart';

const List<OutletModel> availableOutlets = [

  // ── KERALA ──
  OutletModel(
    id: 'reportertv',
    name: 'Reporter TV',
    rssUrl: 'https://www.reporterlive.com/rss',
    category: 'Kerala',
    language: 'Malayalam',
    emoji: '📺',
  ),
  OutletModel(
    id: 'mathrubhumi',
    name: 'Mathrubhumi',
    rssUrl: 'https://www.mathrubhumi.com/rss',
    category: 'Kerala',
    language: 'Malayalam',
    emoji: '📰',
  ),

  // ── INDIA ──
  OutletModel(
    id: 'newsminute',
    name: 'The News Minute',
    rssUrl: 'https://www.thenewsminute.com/rss',
    category: 'India',
    language: 'English',
    emoji: '🗞️',
  ),
  OutletModel(
    id: 'newslaundry',
    name: 'Newslaundry',
    rssUrl: 'https://www.newslaundry.com/feed',
    category: 'India',
    language: 'English',
    emoji: '🗞️',
  ),
  OutletModel(
    id: 'wire',
    name: 'The Wire',
    rssUrl: 'https://thewire.in/rss',
    category: 'India',
    language: 'English',
    emoji: '🗞️',
  ),
  OutletModel(
    id: 'scroll',
    name: 'Scroll.in',
    rssUrl: 'https://feeds.feedburner.com/ScrollinArticles',
    category: 'India',
    language: 'English',
    emoji: '🗞️',
  ),
  OutletModel(
    id: 'hindu',
    name: 'The Hindu',
    rssUrl: 'https://www.thehindu.com/feeder/default.rss',
    category: 'India',
    language: 'English',
    emoji: '📰',
  ),
  OutletModel(
    id: 'telegraph',
    name: 'The Telegraph',
    rssUrl: 'https://www.telegraphindia.com/rss/feeds/latest.xml',
    category: 'India',
    language: 'English',
    emoji: '📰',
  ),

  // ── WORLD ──
  OutletModel(
    id: 'reuters',
    name: 'Reuters',
    rssUrl: 'https://feeds.reuters.com/reuters/topNews',
    category: 'World',
    language: 'English',
    emoji: '🌍',
  ),
  OutletModel(
    id: 'aljazeera',
    name: 'Al Jazeera',
    rssUrl: 'https://www.aljazeera.com/xml/rss/all.xml',
    category: 'World',
    language: 'English',
    emoji: '🌍',
  ),
  OutletModel(
    id: 'ap',
    name: 'Associated Press',
    rssUrl: 'https://feeds.apnews.com/apf-topnews',
    category: 'World',
    language: 'English',
    emoji: '🌍',
  ),
];