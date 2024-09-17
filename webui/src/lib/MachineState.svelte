<script>
	import CircularProgress from '@smui/circular-progress';
	import store from './store.js';
	import { onMount } from 'svelte';

	let machine_data = {
		state: 'off',
		head_temp: 0
	};
	let temp = 0.5;
	onMount(() => {
		store.subscribe((value) => {
			if (typeof value === 'string') {
				machine_data = JSON.parse(value);
			}
		});
	});
</script>

<h1>Machine State</h1>
<p>Machine state: {machine_data.state}</p>
<p>
	metal: {machine_data.head_temp}&deg;C<br />
	goal:{machine_data.temp_goal}&deg;C<br />
	steam:{machine_data.steam_temp}&deg;C <br />
	pressure: {machine_data.pressure} bar <br />
	flow: {machine_data.flow} ml/s<br />
</p>
