const messages = [
  { chat: 'Dev Team', sender: 'Alex', body: 'Standup in 10 min', priority: 'work' },
  { chat: 'Family', sender: 'Sam', body: 'Dinner at 7?', priority: 'personal' },
  { chat: 'Ops', sender: 'Bot', body: 'Latency spike detected', priority: 'urgent' },
  { chat: 'Trading Desk', sender: 'Leah', body: 'NQ levels updated', priority: 'work' }
];

const list = document.getElementById('messageList');
const watchList = document.getElementById('watchList');
const urgentToggle = document.getElementById('urgentToggle');

function render() {
  const showUrgentOnly = urgentToggle.checked;
  const filtered = showUrgentOnly ? messages.filter((m) => m.priority === 'urgent') : messages;

  list.innerHTML = filtered.map((m) => `
    <li class="msg">
      <div class="top">
        <span class="chat">${m.chat}</span>
        <span class="pill ${m.priority}">${m.priority.toUpperCase()}</span>
      </div>
      <div class="body">${m.sender}: ${m.body}</div>
    </li>
  `).join('');

  watchList.innerHTML = filtered.slice(0, 3).map((m) => `
    <li><b>${m.chat}</b><span>${m.body}</span></li>
  `).join('');
}

urgentToggle.addEventListener('change', render);
render();
